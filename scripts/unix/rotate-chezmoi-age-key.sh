#!/usr/bin/env bash
#
# Rotates the chezmoi age identity and its passphrase, re-encrypting every
# encrypted file in the source tree to the new recipient.
#
# Re-encryption reads plaintext from the applied targets in $HOME rather than
# decrypting the old ciphertext, so the old identity is never needed. That is
# why every encrypted target has to exist before we start.
#
# Ordering is chosen so cancelling is safe: nothing is modified until the new
# key.txt.age has been written, which is the step that asks for the new
# passphrase. The old local key is backed up rather than replaced in place.
#
# Pass --dry-run to see the preflight and the file list without changing
# anything.

set -euo pipefail

dry_run=0
if [ "${1:-}" = "--dry-run" ]; then
  dry_run=1
fi

die() {
  echo "rotate-chezmoi-age-key: $*" 1>&2
  exit 1
}

source_dir="$(chezmoi source-path)"
repo_root="$(cd "$source_dir/.." && pwd)"
key_path="$HOME/.config/chezmoi/key.txt"
config_tmpl="$source_dir/.chezmoi.toml.tmpl"

# chezmoi init is part of the rotation, and on a vm the config template
# regenerates machine_id from randAlphaNum. Rotate from a real machine.
location="$(chezmoi execute-template '{{ .location }}')"
[ "$location" != "vm" ] || die "refusing to rotate from a vm; machine_id would be regenerated"

[ -f "$key_path" ] || die "no age key at $key_path"
[ -f "$config_tmpl" ] || die "no config template at $config_tmpl"

if [ -n "$(git -C "$repo_root" status --porcelain)" ]; then
  die "$repo_root has uncommitted changes; commit or stash them first"
fi

# chezmoi orders the encrypted_ attribute first, so this prefix finds them all.
# The list is printed below for confirmation, which catches any miss.
targets=()
while IFS= read -r src; do
  [ -n "$src" ] || continue
  target="$(chezmoi target-path "$src")"
  [ -f "$target" ] || die "target $target does not exist; run 'chezmoi apply' first"
  targets+=("$target")
done < <(find "$source_dir" -type f -name 'encrypted_*' | sort)

[ "${#targets[@]}" -gt 0 ] || die "found no encrypted files under $source_dir"

echo "Rotating the age identity used by $repo_root"
echo "These ${#targets[@]} file(s) will be re-encrypted from their current plaintext:"
printf '  %s\n' "${targets[@]}"
echo

if [ "$dry_run" -eq 1 ]; then
  echo "Dry run, stopping before any change."
  exit 0
fi

printf 'Continue? [y/N] '
read -r reply
case "$reply" in
  y | Y | yes | YES) ;;
  *) die "aborted" ;;
esac

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

chezmoi age-keygen -o "$tmp_dir/key.txt"
new_recipient="$(chezmoi age-keygen -y "$tmp_dir/key.txt")"
echo "New recipient: $new_recipient"

echo "Enter the NEW passphrase (you will be asked twice):"
chezmoi age encrypt --passphrase --output="$source_dir/key.txt.age" "$tmp_dir/key.txt"

# The literal lives in the $age_recipient template variable, which feeds both
# [age] recipient and [data] age_recipient, so there is only one line to rewrite.
# -F throughout: a leading $ in a basic regex is not matched literally by every
# grep implementation, and the pattern has to start with one.
matches="$(grep -cF '$age_recipient := "age1' "$config_tmpl" || true)"
[ "$matches" = "1" ] || die "expected 1 \$age_recipient line in $config_tmpl, found $matches"
# BSD and GNU sed disagree on -i, so write out and move back.
sed 's|\(\$age_recipient := \)"age1[a-z0-9]*"|\1"'"$new_recipient"'"|' \
  "$config_tmpl" > "$config_tmpl.new"
grep -qF "\$age_recipient := \"$new_recipient\"" "$config_tmpl.new" ||
  die "failed to rewrite the recipient in $config_tmpl"
mv "$config_tmpl.new" "$config_tmpl"

backup="$key_path.rotated-$(date +%Y%m%dT%H%M%S)"
cp "$key_path" "$backup"
echo "Old key backed up to $backup"
cp "$tmp_dir/key.txt" "$key_path"
chmod 600 "$key_path"

# Regenerates ~/.config/chezmoi/chezmoi.toml with the new recipient. Safe to
# re-run because every prompt in the config template is a prompt*Once function.
chezmoi init

for target in "${targets[@]}"; do
  echo "Re-encrypting $target"
  chezmoi add --encrypt "$target"
done

echo
echo "Done. Review and commit:"
git -C "$repo_root" status --short
echo
echo "Other machines will prompt for the new passphrase on their next 'chezmoi apply'."
