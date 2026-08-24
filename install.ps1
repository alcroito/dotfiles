# Windows

# Install dotfiles
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Same location install.sh uses, and on PATH via the PowerShell profile, so
# later `chezmoi` calls by hand resolve instead of depending on the installer's
# cwd-relative .\bin default.
$binDir = Join-Path $env:USERPROFILE '.local\bin'

# Any arguments passed to this script are forwarded to `chezmoi init`
# (e.g. `--promptString "home or work or vm=vm"` to run non-interactively).
# Splat @args (rather than string-interpolating) so values containing spaces
# survive as single arguments.
#
# The age identity is decrypted by the [hooks.apply.pre] hook that
# .chezmoi.toml.tmpl writes, which runs before the apply reads the source state.
#
# --keep-going so one unusable file or failing script does not abandon every
# target after it on a fresh machine.
$chezmoiInstaller = [scriptblock]::Create((irm 'https://get.chezmoi.io/ps1'))
& $chezmoiInstaller -b $binDir init --apply --keep-going @args https://github.com/alcroito/dotfiles.git
