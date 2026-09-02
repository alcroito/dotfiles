# alcroito dotfiles 🛠

### Unix

Execute the install script (downloaded via curl):

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/alcroito/dotfiles/main/install.sh)"
```

### Windows

Run the following command in PowerShell **NOT** as an administrator:

```powershell
iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/alcroito/dotfiles/main/install.ps1'))
```

## VM (non-interactive)

Same as above, but with the `location` prompt predefined as `vm`, so chezmoi
applies without asking anything (the `.chezmoi.toml.tmpl` config derives every
other setting from `location=vm`).

### Unix

The install script forwards any arguments after `--` to `chezmoi init`:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/alcroito/dotfiles/main/install.sh)" -- --promptString "home or work or vm or agent=vm"
```

### Windows

Run the following command in PowerShell **NOT** as an administrator. The install
script forwards its arguments to `chezmoi init`:

```powershell
& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/alcroito/dotfiles/main/install.ps1'))) --promptString "home or work or vm or agent=vm"
```

## Agent (minimal, non-interactive)

`location=agent` installs the smallest toolset an LLM agent needs to ssh in and
work on the machine:

### Unix

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/alcroito/dotfiles/main/install.sh)" -- --promptString "home or work or vm or agent=agent"
```

### Windows

```powershell
& ([scriptblock]::Create((irm 'https://raw.githubusercontent.com/alcroito/dotfiles/main/install.ps1'))) --promptString "home or work or vm or agent=agent"
```

## General Usage

```bash
chezmoi init --apply --verbose https://github.com/alcroito/dotfiles.git
```
