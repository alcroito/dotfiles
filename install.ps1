# Windows

# Install dotfiles
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
iex "&{$(irm 'https://get.chezmoi.io/ps1')} init --apply https://github.com/alcroito/dotfiles.git"
