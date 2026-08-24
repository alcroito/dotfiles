# Use fancy theme
try {
    Import-Module posh-git -ErrorAction Stop
} catch {
    Write-Warning "posh-git not installed, git prompt info disabled. Install it with: Install-Module -Name posh-git"
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config '~/.cat_custom.omp.yaml' | Invoke-Expression
} else {
    Write-Warning "oh-my-posh not found on PATH, prompt theme disabled. Install it with: scoop install oh-my-posh"
}

# replace 'Ctrl+t' and 'Ctrl+r' with your preferred bindings:
#Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# Increase PS command history
Set-PSReadlineOption -MaximumHistoryCount 50000

# Not sure
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Aliases
# short form of `Set-Alias which Get-Command`
sal which gcm
sal vim nvim
#sal rr yazi
sal v nvim
sal lg lazygit

function rr {
    $tmp = (New-TemporaryFile).FullName
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
    }
    Remove-Item -Path $tmp
}

Function amend { git commit --amend --verbose}
Function gup { git pull --rebase }
Function grhh { git reset --hard }
Function undo { git reset --hard HEAD~1 }
Function gcp { git cherry-pick $args[0] }
Function gst { git status }
Function gc { git commit }
Function gco {
  git checkout $args[0]
}
Function take {
  mkdir $args[0]
  cd $args[0]
}

# Set default editor
$env:EDITOR = "nvim.exe"

. "$PSScriptRoot\Microsoft.PowerShell_profile_machine_specific.ps1"

# For chezmoi bin dir
$env:Path = "$HOME\bin;" + $env:Path
$env:Path = "$HOME\.local\bin;" + $env:Path

# FZF options
$env:FZF_DEFAULT_OPTS='--color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108 --color info:108,prompt:109,spinner:108,pointer:168,marker:168'
$env:FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind ?:toggle-preview"
#Import-Module PSFzf

# Set yazi preview helper. Git ships file(1); prefer scoop's per-user install,
# fall back to a Git for Windows system install.
$yaziFile = Join-Path $env:USERPROFILE 'scoop\apps\git\current\usr\bin\file.exe'
if (-not (Test-Path $yaziFile)) {
    $yaziFile = 'C:\Program Files\Git\usr\bin\file.exe'
}
$env:YAZI_FILE_ONE = $yaziFile

# Some setting when ssh-ing in
if($env:LC_TERMINAL -eq "iTerm2") {
  $ThemeSettings.Options.ConsoleTitle = $false
}

# https://stackoverflow.com/questions/45068442/running-vs-2017-build-tools-in-windows-powershell

<#
.SYNOPSIS
    Invokes the specified batch file and retains any environment variable changes it makes.
.DESCRIPTION
    Invoke the specified batch file (and parameters), but also propagate any
    environment variable changes back to the PowerShell environment that
    called it.
.PARAMETER Path
    Path to a .bat or .cmd file.
.PARAMETER Parameters
    Parameters to pass to the batch file.
.EXAMPLE
    C:\PS> Invoke-BatchFile "$env:ProgramFiles\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"
    Invokes the vcvarsall.bat file.  All environment variable changes it makes will be
    propagated to the current PowerShell session.
.NOTES
    Author: Lee Holmes
#>
function Invoke-BatchFile
{
    param([string]$Path, [string]$Parameters)

    $tempFile = [IO.Path]::GetTempFileName()

    ## Store the output of cmd.exe.  We also ask cmd.exe to output
    ## the environment table after the batch file completes
    cmd.exe /c " `"$Path`" $Parameters && set " > $tempFile

    ## Go through the environment variables in the temp file.
    ## For each of them, set the variable in our local environment.
    Get-Content $tempFile | Foreach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            Set-Content "env:\$($matches[1])" $matches[2]
        }
        else {
            $_
        }
    }

    Remove-Item $tempFile
}

#$shimPath = "$env:USERPROFILE\AppData\Local\mise\shims"
#$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
#$newPath = $currentPath + ";" + $shimPath
#[Environment]::SetEnvironmentVariable('Path', $newPath, 'User')

mise activate pwsh | Out-String | Invoke-Expression
# Atuin's PSReadLine hook captures `atuin history start` through the pipeline,
# which waits for the pipe to reach EOF. On Windows a daemon autostarted by that
# call inherits the pipe handle and outlives the command, so the first command of
# a fresh session hangs until Ctrl-C. Patch the generated init to read the single
# line it needs instead. atuinsh/atuin#3502 fixed the same thing for bash/zsh/fish
# by closing fd 3; the PowerShell integration still has it. FileName = "atuin"
# mirrors what the hook's own `history end` step already does. Every local here is
# atuin-prefixed: the hook keeps the typed command in $line and returns it, so a
# plain $line assignment would make the shell execute the history id instead.
if (Get-Command atuin -ErrorAction SilentlyContinue) {
    $atuinInit = (atuin init powershell --disable-up-arrow | Out-String)
    $atuinNeedle = '$script:atuinHistoryId = atuin history start --hook --command-from-env'
    $atuinPatch = @'
$script:atuinHistoryId = $(
                $atuinPsi = New-Object System.Diagnostics.ProcessStartInfo
                $atuinPsi.FileName = "atuin"
                $atuinPsi.Arguments = "history start --hook --command-from-env"
                $atuinPsi.UseShellExecute = $false
                $atuinPsi.RedirectStandardOutput = $true
                $atuinPsi.RedirectStandardError = $true
                $atuinPsi.CreateNoWindow = $true
                $atuinProc = [System.Diagnostics.Process]::Start($atuinPsi)
                $atuinProc.StandardOutput.ReadLine()
                $null = $atuinProc.WaitForExit(5000)
            )
'@
    $atuinPatched = $atuinInit.Replace($atuinNeedle, $atuinPatch)
    if ($atuinPatched -eq $atuinInit) {
        Write-Warning "atuin init no longer contains the 'history start' capture this profile patches, so the first command of a new session may hang until Ctrl-C"
    }
    $atuinPatched | Invoke-Expression
} else {
    Write-Warning "atuin not found on PATH, shell history disabled. Install it with: scoop install atuin"
}
