# alcroito dotfiles 🛠

### Unix

Execute the install script (downloaded via curl):

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/alcroito/dotfiles/main/install.sh)"
```

### Windows

Run the following command in PowerShell as administrator:

```powershell
iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/alcroito/dotfiles/main/install.ps1')) (not there yet)
```

## Usage

```bash
chezmoi init --apply --verbose https://github.com/alcroito/dotfiles.git
```
