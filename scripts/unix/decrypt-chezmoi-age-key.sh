#!/usr/bin/env sh
#
# Puts a current age identity at ~/.config/chezmoi/key.txt so the encrypted
# GitHub token files can be applied.
#
# Called from two places:
#   - install.sh, after `chezmoi init` and before the first `chezmoi apply`.
#     .chezmoiignore gates the encrypted token files on this identity existing
#     and is evaluated before any script in the apply runs, so the identity has
#     to be in place beforehand for the tokens to land in that first pass.
#   - run_onchange_before_005_decrypt_age_key, which is what picks up an
#     identity rotated on another machine on a later apply.
#
# The local key's recipient is compared against the configured one, so an
# identity rotated elsewhere is detected here instead of silently leaving behind
# a key that decrypts nothing.
#
# This never fails its caller.
#
# Usage: decrypt-chezmoi-age-key.sh [recipient]

warn() {
  echo "decrypt_age_key: $1" 1>&2
}

warn_unauthenticated() {
  warn "mise and chezmoi will make unauthenticated GitHub API calls and may be rate limited"
  warn "run 'chezmoi apply' from an interactive shell to finish setup"
}

# CHEZMOI_EXECUTABLE is exported by chezmoi to the scripts it runs; install.sh
# sets it explicitly. Neither caller can rely on chezmoi being on PATH.
chezmoi="${CHEZMOI_EXECUTABLE:-$(command -v chezmoi 2>/dev/null)}"
if [ -z "$chezmoi" ]; then
  chezmoi="$HOME/.local/bin/chezmoi"
fi
if [ ! -x "$chezmoi" ]; then
  warn "no chezmoi executable found at $chezmoi, skipping age key decryption"
  warn_unauthenticated
  exit 0
fi

# The override exists so the missing-key and stale-key branches can be checked
# without breaking the real key.
key_path="${CHEZMOI_AGE_KEY_PATH:-$HOME/.config/chezmoi/key.txt}"

# Both callers pass the recipient, and both are only emitted when
# install_github_tokens is true, so this script does not re-check the flag. The
# fallback template deliberately contains no quotes: Windows PowerShell 5.1
# passes arguments to native commands in Legacy mode, which drops embedded
# double quotes, so a `hasKey . "x"` template would arrive at chezmoi malformed.
recipient="$1"
if [ -z "$recipient" ]; then
  recipient="$("$chezmoi" execute-template '{{ .age_recipient }}' 2>/dev/null)"
fi

source_dir="${CHEZMOI_SOURCE_DIR:-$("$chezmoi" source-path 2>/dev/null)}"
source_key="$source_dir/key.txt.age"

if [ -z "$recipient" ]; then
  warn "no age recipient configured, nothing to do"
  exit 0
fi

if [ ! -f "$source_key" ]; then
  warn "$source_key is missing"
  warn_unauthenticated
  exit 0
fi

if [ -f "$key_path" ]; then
  if [ "$("$chezmoi" age-keygen -y "$key_path" 2>/dev/null)" = "$recipient" ]; then
    exit 0
  fi
  warn "local age key does not match the configured recipient, re-decrypting"
fi

# chezmoi opens /dev/tty directly for the passphrase, so test that it opens
# rather than testing whether stdin is a terminal.
if ! { : < /dev/tty; } 2>/dev/null; then
  warn "no TTY available, skipping age key decryption"
  warn_unauthenticated
  exit 0
fi

mkdir -p "$(dirname "$key_path")"

# chezmoi's own prompt is a bare "Enter passphrase:", so say what is being asked
# for before it appears.
echo "decrypt_age_key: unlocking the chezmoi age identity, which decrypts the GitHub API token files"
echo "decrypt_age_key: a wrong or refused passphrase is not fatal, the apply continues unauthenticated"
if ! "$chezmoi" age decrypt --passphrase --output "$key_path.new" "$source_key"; then
  warn "age key decryption failed, keeping any existing key"
  warn_unauthenticated
  rm -f "$key_path.new"
  exit 0
fi
chmod 600 "$key_path.new"
mv "$key_path.new" "$key_path"
echo "decrypt_age_key: age identity installed"
