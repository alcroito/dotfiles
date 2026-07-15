#!/usr/bin/env bash
#
# chezmoi [secret].command wrapper for ephemeral, headless VMs.
#
# These hosts have no keyring, so the local session key lives on the filesystem
# (PROTON_PASS_KEY_PROVIDER=fs). To limit blast radius we do NOT keep the full
# account session around: bootstrap once via interactive login, mint a short-lived
# (1 day) personal access token scoped to just the SSH key item, drop the account
# session, then use only that PAT. The PAT is named after this host (hostname +
# primary IPv4) so re-bootstrapping after a reboot or expiry reuses the name
# instead of piling up tokens.
#
# Invoked two ways:
#   - as chezmoi's [secret].command, with pass-cli arguments appended (runs them)
#   - by the login script with no arguments, just to bootstrap up front

export PROTON_PASS_KEY_PROVIDER=fs

# Vault-level access: item-scoped PATs can't resolve a pass://VaultName/ItemName
# reference (they can't list the vault by name), so the whole vault is granted.
PASS_VAULT="PersonalSecrets"

pat_name() {
  local host ip
  host="$(hostname 2>/dev/null || echo unknown)"
  ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
  [ -n "$ip" ] || ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
  [ -n "$ip" ] || ip="noip"
  printf 'chezmoi-%s-%s' "$host" "$ip" | tr -c 'A-Za-z0-9._-' '-'
}

bootstrap() {
  local name token existing
  name="$(pat_name)"
  echo "proton pass: no usable session; bootstrapping PAT '$name' via interactive login" 1>&2

  # Clear any stale local session so the PAT login below doesn't hit "Already authenticated".
  pass-cli logout 1>&2 || pass-cli logout --force 1>&2 || true

  # Interactive account login (web flow); the URL is printed to stderr.
  pass-cli login 1>&2

  # Reuse this host's token: delete an existing one with the same name to avoid piling up.
  if command -v jq >/dev/null 2>&1; then
    existing="$(pass-cli pat list --output json 2>/dev/null \
      | jq -r --arg n "$name" '[.[] | select(.name==$n) | .pat_id][0] // empty')"
    if [ -n "$existing" ]; then
      echo "proton pass: replacing existing PAT '$name' ($existing)" 1>&2
      pass-cli pat delete --personal-access-token-id "$existing" 1>&2 || true
    fi
  fi

  # Extract the token by its "pst_<token>::<key>" shape so this works whether the
  # CLI prints human or JSON output (the format has varied across versions).
  token="$(pass-cli pat create --name "$name" --expiration 1d --output json \
    | grep -oE 'pst_[^"[:space:]]+' | head -n1)"
  if [ -z "$token" ]; then
    echo "proton pass: could not extract a 'pst_...::...' token from 'pat create' output" 1>&2
    exit 1
  fi
  pass-cli pat access grant --pat-name "$name" \
    --vault-name "$PASS_VAULT" --role viewer 1>&2

  # Drop the full-account session, then re-login with only the scoped PAT.
  pass-cli logout 1>&2 || pass-cli logout --force 1>&2 || true
  PROTON_PASS_PERSONAL_ACCESS_TOKEN="$token" pass-cli login 1>&2
}

# `test` checks the session actually works against the server (catches expiry/revocation).
pass-cli test >/dev/null 2>&1 || bootstrap

if [ "$#" -gt 0 ]; then
  exec pass-cli "$@"
fi
