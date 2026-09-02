#!/usr/bin/env bash
#
# Sets up a freshly created VM from this machine, unattended, so an llm harness
# can ssh in afterwards.
#
# The only thing this does that chezmoi cannot is get past a VM that has no key
# installed yet: it logs in with a well known password and seeds the age
# identity. Everything else, authorized_keys included, is left to the chezmoi
# apply it kicks off, which is what makes the host reachable by key.
#
# The age identity is copied rather than its passphrase being typed, because
# `chezmoi age decrypt` opens /dev/tty itself and the Windows helper refuses to
# prompt at all when input is redirected. With ~/.config/chezmoi/key.txt already
# in place the decrypt helper matches the recipient and exits without prompting,
# which is what makes the run unattended.
#
# Usage: bootstrap-remote-vm.sh [-u user] [-l location] <host>

set -euo pipefail

PASSWORD_FILE="${BOOTSTRAP_PASSWORD_FILE:-$HOME/.config/dotfiles/coin_vm_passwords.txt}"
AGE_KEY="${BOOTSTRAP_AGE_KEY:-$HOME/.config/chezmoi/key.txt}"
INSTALL_URL="${BOOTSTRAP_INSTALL_URL:-https://raw.githubusercontent.com/alcroito/dotfiles/main/install.sh}"
LOCATION_PROMPT="home or work or vm or agent"

user="qt"
location="agent"

die() {
  echo "bootstrap-remote-vm: $*" 1>&2
  exit 1
}

usage() {
  echo "Usage: $0 [-u user] [-l home|work|vm|agent] <host>" 1>&2
  exit 2
}

while getopts ':u:l:h' opt; do
  case "$opt" in
    u) user="$OPTARG" ;;
    l) location="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))
[ "$#" -eq 1 ] || usage
host="$1"

case "$location" in
  home | work | vm | agent) ;;
  *) die "unknown location '$location'" ;;
esac

################################################################################
# Preflight
################################################################################

# Not in the repo and .chezmoiignore'd, so it has to be put here by hand. Without
# it there is no way in, hence a hard failure rather than a prompt.
if [ ! -r "$PASSWORD_FILE" ]; then
  die "no password list at $PASSWORD_FILE
Create it with one password per line (# comments and blank lines are skipped)
and chmod 600 it. It is deliberately not stored in the dotfiles repo."
fi

[ -r "$AGE_KEY" ] ||
  die "no age identity at $AGE_KEY; run 'chezmoi apply' here first so it gets decrypted"

sshpass_bin="$(command -v sshpass || true)"
expect_bin="$(command -v expect || true)"
[ -n "$sshpass_bin" ] || [ -n "$expect_bin" ] ||
  die "need sshpass or expect for the password login; macOS ships expect, otherwise install one"

mapfile -t passwords < <(grep -v '^[[:space:]]*#' "$PASSWORD_FILE" | grep -v '^[[:space:]]*$')
[ "${#passwords[@]}" -gt 0 ] || die "no passwords found in $PASSWORD_FILE"

tmp_dir="$(mktemp -d)"
chmod 700 "$tmp_dir"
trap 'rm -rf "$tmp_dir"' EXIT
pass_file="$tmp_dir/pass"

SSH_OPTS=(
  -o StrictHostKeyChecking=accept-new
  -o ConnectTimeout=10
  -o LogLevel=ERROR
  # One attempt per connection. Without this ssh prompts three times, the
  # wrapper below answers each with the same password, and a list of three
  # passwords costs nine authentication failures - enough to trip a lockout
  # policy on a Windows target.
  -o NumberOfPasswordPrompts=1
)

################################################################################
# ssh and scp, with or without a password
################################################################################

# The password goes through a 0600 file rather than a command line argument so it
# stays out of the process list.
cat > "$tmp_dir/askpass.exp" <<'EXPECT'
#!/usr/bin/env expect -f
set timeout -1
# First usable line, not the whole file: reading a file that still has the
# comments from the password list sends the comments as the password.
set fh [open [lindex $argv 0] r]
set pass ""
while {[gets $fh line] >= 0} {
  set line [string trim $line]
  if {$line eq "" || [string index $line 0] eq "#"} { continue }
  set pass $line
  break
}
close $fh
spawn -noecho {*}[lrange $argv 1 end]
# Answered once and once only: re-sending the same password at a second prompt
# just spends another authentication failure. Exit 5 matches what sshpass reports
# for a rejected password, which is what the caller looks for.
set answered 0
expect {
  "*assword:*" {
    if {$answered} {
      close
      wait
      exit 5
    }
    set answered 1
    send -- "$pass\r"
    exp_continue
  }
  "*(yes/no*)?*" { send -- "yes\r"; exp_continue }
  eof
}
catch wait result
exit [lindex $result 3]
EXPECT

# Set once the password phase has found a working password; empty means key auth.
auth_mode="key"

run_with_password() {
  if [ -n "$sshpass_bin" ]; then
    "$sshpass_bin" -f "$pass_file" "$@"
  else
    "$expect_bin" "$tmp_dir/askpass.exp" "$pass_file" "$@"
  fi
}

# Quiet, no pty: the remote side is all non-interactive and a pty only muddles
# the output. -T also keeps expect from matching on remote output.
remote() {
  local ssh_args=(-T "${SSH_OPTS[@]}")
  if [ "$auth_mode" = "key" ]; then
    ssh "${ssh_args[@]}" -o BatchMode=yes "$user@$host" "$@"
  else
    run_with_password ssh "${ssh_args[@]}" -o PubkeyAuthentication=no "$user@$host" "$@"
  fi
}

copy_to_remote() {
  local src="$1" dst="$2"
  if [ "$auth_mode" = "key" ]; then
    scp "${SSH_OPTS[@]}" -o BatchMode=yes -q "$src" "$user@$host:$dst"
  else
    run_with_password scp "${SSH_OPTS[@]}" -o PubkeyAuthentication=no -q "$src" "$user@$host:$dst"
  fi
}

################################################################################
# Phase 1: get a shell
################################################################################

# A rebuilt VM reuses its address with a new host key.
ssh-keygen -R "$host" > /dev/null 2>&1 || true

echo "==> connecting to $user@$host"
if ssh -T "${SSH_OPTS[@]}" -o BatchMode=yes "$user@$host" true 2>/dev/null; then
  echo "    key authentication already works"
else
  auth_mode="password"
  found=""
  for password in "${passwords[@]}"; do
    printf '%s\n' "$password" > "$pass_file"
    chmod 600 "$pass_file"
    rc=0
    remote exit > /dev/null 2>&1 || rc=$?
    # Judged on the transport rather than on the command: ssh exits 255 when the
    # connection or authentication fails, and sshpass 5 when the password is
    # rejected. Anything else means we are in, and the status came from the
    # remote shell, which on a Windows target has no `true` to run and used to
    # make a good password look like a bad one.
    case "$rc" in
      255 | 5) continue ;;
      *)
        found="yes"
        break
        ;;
    esac
  done
  [ -n "$found" ] || die "none of the ${#passwords[@]} password(s) in $PASSWORD_FILE worked for $user@$host"
  echo "    logged in with a password from $PASSWORD_FILE"
fi

# In password mode this goes through expect, whose stdout carries the pty's CRs
# and ssh's own password prompt, so the answer needs framing to be picked out of
# it. Exit codes are used everywhere else, which is why this is the only place
# that cares.
os_out="$(remote 'echo "__OS__$(uname -s 2>/dev/null || echo Windows)__"' || true)"
os="$(printf '%s' "$os_out" | tr -d '\r' | sed -n 's/.*__OS__\([A-Za-z]*\)__.*/\1/p' | tail -1)"

# cmd.exe and powershell leave a POSIX $( ) alone, so the marker comes back with
# the substitution unexpanded. Seeing the marker but no name inside it is itself
# the answer.
if [ -z "$os" ] && printf '%s' "$os_out" | grep -q '__OS__'; then
  os="Windows"
fi

[ -n "$os" ] || die "could not determine the remote OS; got: $os_out"
echo "==> remote reports $os"
case "$os" in
  # A macOS CI VM already has homebrew, a selected Xcode and passwordless sudo,
  # which is what made this platform look like work: install.sh skips its command
  # line tools branch when xcode-select resolves, and the brew bootstrap is a
  # no-op. A bare macOS install would still need both.
  Linux | Darwin) ;;
  *) die "Windows targets are not supported yet (gsudo elevation cannot be answered over ssh)" ;;
esac

################################################################################
# Phase 2: passwordless sudo
################################################################################

# Every package script in the dotfiles calls bare sudo, so without this the
# apply blocks forever on a prompt nothing is there to answer.
echo "==> checking passwordless sudo"
if remote 'sudo -n true' > /dev/null 2>&1; then
  echo "    already available"
elif [ "$auth_mode" = "password" ]; then
  echo "    granting it via /etc/sudoers.d/99-chezmoi-bootstrap"
  printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$user" > "$tmp_dir/sudoers"

  # sudo -S wants the password on stdin, and expect gives the remote command a
  # pty of its own, so forwarding our stdin is not reliable across both
  # backends. The password takes a short trip through a 0600 file on the VM
  # instead, removed immediately afterwards. It is a well known throwaway
  # password that is already sitting in cleartext on this machine.
  copy_to_remote "$tmp_dir/sudoers" '.chezmoi-bootstrap-sudoers'
  copy_to_remote "$pass_file" '.chezmoi-bootstrap-pass'

  # visudo -cf validates the file before it is installed, so a bad line cannot
  # leave sudo unusable.
  remote '
    set -e
    chmod 600 ~/.chezmoi-bootstrap-sudoers ~/.chezmoi-bootstrap-pass
    cleanup() { rm -f ~/.chezmoi-bootstrap-sudoers ~/.chezmoi-bootstrap-pass; }
    trap cleanup EXIT
    sudo -S -p "" visudo -cf ~/.chezmoi-bootstrap-sudoers < ~/.chezmoi-bootstrap-pass > /dev/null
    sudo -S -p "" install -m 440 -o 0 -g 0 \
      ~/.chezmoi-bootstrap-sudoers /etc/sudoers.d/99-chezmoi-bootstrap < ~/.chezmoi-bootstrap-pass
  ' || die "could not grant passwordless sudo"

  remote 'sudo -n true' > /dev/null 2>&1 ||
    die "sudo still asks for a password; grant $user NOPASSWD sudo on the VM template"
else
  die "sudo needs a password but this run authenticated with a key, so none was read.
Grant $user NOPASSWD sudo on the VM, or remove its authorized_keys entry and re-run."
fi

################################################################################
# Phase 3: seed the age identity
################################################################################

echo "==> seeding the age identity"
remote 'mkdir -p ~/.config/chezmoi && chmod 700 ~/.config/chezmoi'
copy_to_remote "$AGE_KEY" '.config/chezmoi/key.txt'
remote 'chmod 600 ~/.config/chezmoi/key.txt'

################################################################################
# Phase 4: apply the dotfiles
################################################################################

echo "==> running the dotfiles installer with location=$location"
installer_rc=0
remote "sh -c \"\$(curl -fsSL $INSTALL_URL)\" -- --promptString '$LOCATION_PROMPT=$location'" ||
  installer_rc=$?
if [ "$installer_rc" -ne 0 ]; then
  echo "    installer exited $installer_rc; checking what landed anyway" 1>&2
fi

################################################################################
# Phase 5: verify what an agent will rely on
################################################################################

echo "==> verifying"
fail=0
check() {
  local label="$1" cmd="$2"
  if remote "$cmd" > /dev/null 2>&1; then
    echo "    ok   $label"
  else
    echo "    FAIL $label"
    fail=1
  fi
}

# From here on the key chezmoi installed should be enough, which is the whole
# point of the exercise. When it is not, the rest of the checks stay on the
# connection that does work, so they report on the files rather than all failing
# for the same reason.
bootstrap_mode="$auth_mode"
auth_mode="key"
if remote true > /dev/null 2>&1; then
  echo "    ok   key-only ssh login"
else
  echo "    FAIL key-only ssh login"
  echo "         (checking the rest over the bootstrap connection)"
  fail=1
  auth_mode="$bootstrap_mode"
fi

check "authorized_keys written" 'test -s ~/.ssh/authorized_keys'
check "age identity present" 'test -s ~/.config/chezmoi/key.txt'
check "github token env applied" 'test -s ~/.config/dotfiles/github_env.sh'
check "mise on a non-interactive ssh PATH" 'mise --version'
check "yazi on that PATH too" 'command -v yazi'

if [ "$fail" -ne 0 ] || [ "$installer_rc" -ne 0 ]; then
  echo
  die "the VM is only partly set up; see the failures above"
fi

echo
echo "Done. $user@$host is reachable by key:"
echo "  ssh $user@$host"
