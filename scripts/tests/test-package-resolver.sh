#!/usr/bin/env bash
# Renders pkgs/select over a fixed matrix of (osid, version, groups) and diffs
# the result against the goldens. Runs from any host: pkgs/select reads no
# chezmoi built-ins, so a mac can render the debian 11 or EL10 case.
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
source_dir="$repo_root/home"
fixtures="$repo_root/scripts/tests/fixtures"

update=false
if [ "${1:-}" = "--update" ]; then
  update=true
fi

# chezmoi resolves its source directory from its own config rather than the cwd,
# so the harness passes an explicit --source plus a config that sets nothing
# else. Without this it would render the developer's real source state.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
printf 'sourceDir = "%s"\n' "$source_dir" > "$tmp/config.toml"

phases="bootstrap_root bootstrap prereq system nvim_deps nvim mise bob qt_mise ya psmodule"

# name|osid|version|groups
cases='
ubuntu-full|linux-ubuntu|24|"core" "extra" "nvim_deps" "nvim"
ubuntu-minimal|linux-ubuntu|24|"core"
debian-11-full|linux-debian|11|"core" "extra" "nvim_deps" "nvim"
debian-12-full|linux-debian|12|"core" "extra" "nvim_deps" "nvim"
fedora-42-full|linux-fedora|42|"core" "extra" "nvim_deps" "nvim"
fedora-43-full|linux-fedora|43|"core" "extra" "nvim_deps" "nvim"
rocky-9-full|linux-rocky|9|"core" "extra" "nvim_deps" "nvim"
rocky-10-full|linux-rocky|10|"core" "extra" "nvim_deps" "nvim"
rhel-9-full|linux-rhel|9|"core" "extra" "nvim_deps" "nvim"
centos-10-full|linux-centos|10|"core" "extra" "nvim_deps" "nvim"
arch-full|linux-arch|9999|"core" "extra" "nvim_deps" "nvim"
alpine-full|linux-alpine|3|"core" "extra" "nvim" "bob"
suse-full|linux-opensuse-leap|15|"core" "extra" "nvim_deps" "nvim"
darwin-full|darwin|9999|"core" "extra" "nvim" "bob"
darwin-minimal|darwin|9999|"core"
windows-full|windows|9999|"core" "extra" "nvim" "qt_deps"
windows-minimal|windows|9999|"core"
'

render_case() {
  local osid=$1 version=$2 groups=$3 phase
  for phase in $phases; do
    printf '=== %s\n' "$phase"
    printf '{{ includeTemplate "pkgs/select" (dict "data" . "osid" "%s" "version" %s "groups" (list %s) "phase" "%s") }}\n' \
      "$osid" "$version" "$groups" "$phase" > "$tmp/probe.tmpl"
    chezmoi --source "$source_dir" --config "$tmp/config.toml" \
      execute-template < "$tmp/probe.tmpl" | jq -S .
  done
}

mkdir -p "$fixtures"
failed=0
while IFS='|' read -r name osid version groups; do
  [ -n "$name" ] || continue
  actual="$tmp/$name.txt"
  render_case "$osid" "$version" "$groups" > "$actual"
  golden="$fixtures/$name.txt"
  if [ "$update" = true ]; then
    cp "$actual" "$golden"
    echo "updated $name"
  elif [ ! -f "$golden" ]; then
    echo "FAIL $name: no golden at $golden (run with --update to create)" >&2
    failed=1
  elif ! diff -u "$golden" "$actual"; then
    echo "FAIL $name" >&2
    failed=1
  else
    echo "ok   $name"
  fi
done <<EOF
$cases
EOF

exit $failed
