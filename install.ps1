# Windows 11
# Must be run in admin terminal

# Update winget to get rid of blue line and endless spinning in terminal tab
# https://github.com/microsoft/winget-cli/discussions/3964
# December 2023
# https://github.com/microsoft/winget-cli/releases/download/v1.6.3482/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
$url = "https://github.com/microsoft/winget-cli/releases/download/v1.6.3482/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$outpath = "winget.msixbundle"
(New-Object System.Net.WebClient).DownloadFile($url, $outpath)
Add-AppxPackage $outpath

# Install Powershell 7
winget install --id Microsoft.Powershell --source winget

# Install Powershell 7 modules
Set-ExecutionPolicy Bypass -Scope Process -Force;
$pwsh_path = "C:\Program Files\PowerShell\7\pwsh.exe"
& "$pwsh_path" -c 'Install-Module -Name posh-git -Confirm:$False -Force'
& "$pwsh_path" -c 'Install-Module -Name PSFzf -Confirm:$False -Force'
& "$pwsh_path" -c 'Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(''https://ohmyposh.dev/install.ps1''))'

# Install choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install chezmoi via choco
choco install chezmoi --force --confirm

# Consider installing via oneline
# (irm -useb https://get.chezmoi.io/ps1) | powershell -c -

# Install dotfiles
chezmoi init --apply https://github.com/alcroito/dotfiles.git
