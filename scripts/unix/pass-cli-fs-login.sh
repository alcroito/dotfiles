#!/usr/bin/env bash
# chezmoi [secret].command wrapper for headless VMs.
#
# pass-cli has no keyring on a headless VM, so:
#   - use the filesystem key provider (otherwise chezmoi's pass-cli calls query the
#     keyring, hit "local key not found", and force a logout that fails the render)
#   - make sure a session exists before the lookup
# then run the real pass-cli with whatever arguments chezmoi passed.
export PROTON_PASS_KEY_PROVIDER=fs
pass-cli info >/dev/null 2>&1 || pass-cli login 1>&2
exec pass-cli "$@"
