# Windows

# Install dotfiles
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
# Any arguments passed to this script are forwarded to `chezmoi init`
# (e.g. `--promptString "home or work or vm=vm"` to run non-interactively).
# Splat @args (rather than string-interpolating) so values containing spaces
# survive as single arguments.
$chezmoiInstaller = [scriptblock]::Create((irm 'https://get.chezmoi.io/ps1'))
& $chezmoiInstaller init --apply @args https://github.com/alcroito/dotfiles.git
