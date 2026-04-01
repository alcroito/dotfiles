#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Clears chezmoi state tracking for Proton Pass CLI related files and scripts.

.DESCRIPTION
    This script removes chezmoi's state tracking entries (not the actual files) for
    Proton Pass installation, login scripts, and SSH keys that require Windows
    Credential Manager access. After clearing the state tracking, you can re-run
    chezmoi apply from an RDP or local console session to properly install and
    configure Proton Pass CLI.
    
    Note: This does not delete any actual files from your system, only chezmoi's
    internal tracking state.

.PARAMETER Apply
    If specified, automatically runs 'chezmoi apply' after clearing state.
    Default: false (requires manual confirmation)

.PARAMETER ShowAll
    If specified, shows all script state entries before clearing.
    Useful for troubleshooting.

.EXAMPLE
    .\Clear-ChezmoiProtonPassState.ps1
    Clears state and prompts whether to run chezmoi apply

.EXAMPLE
    .\Clear-ChezmoiProtonPassState.ps1 -Apply
    Clears state and automatically runs chezmoi apply

.EXAMPLE
    .\Clear-ChezmoiProtonPassState.ps1 -ShowAll
    Shows all script states and clears Proton Pass related entries

.NOTES
    This script must be run from a Remote Desktop (RDP) session or local console,
    not from an SSH session, as Proton Pass CLI requires Windows Credential Manager
    access which is not available via SSH.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Apply,
    
    [Parameter()]
    [switch]$ShowAll
)

# Check if running in SSH session
if ($env:SSH_CONNECTION -or $env:SSH_CLIENT) {
    Write-Error "This script cannot be run from an SSH session."
    Write-Host "Windows Credential Manager is not accessible via SSH."
    Write-Host "Please run this script from a Remote Desktop (RDP) session or local console."
    exit 1
}

Write-Host "Clearing chezmoi state tracking for Proton Pass CLI related entries..." -ForegroundColor Cyan
Write-Host ""

# Get current state dump
Write-Host "Fetching current chezmoi state..." -ForegroundColor Yellow
$stateDump = chezmoi state dump | ConvertFrom-Json

if (-not $stateDump) {
    Write-Error "Failed to retrieve chezmoi state"
    exit 1
}

$deletedScripts = 0
$deletedFiles = 0

# Debug: Show all script states if requested
if ($ShowAll) {
    Write-Host ""
    Write-Host "DEBUG: All script state entries:" -ForegroundColor Magenta
    $scriptState = $stateDump.scriptState
    if ($scriptState) {
        foreach ($hash in $scriptState.PSObject.Properties.Name) {
            $entry = $scriptState.$hash
            Write-Host "  - $($entry.name) (hash: $($hash.Substring(0,8))...)" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  (none)" -ForegroundColor DarkGray
    }
    Write-Host ""
}

# Delete script state entries for Proton Pass related scripts (both buckets)
Write-Host "Clearing script state tracking..." -ForegroundColor Yellow

# First, clear from scriptState bucket (tracks last run time)
$scriptState = $stateDump.scriptState
$scriptsFoundInScriptState = 0
if ($scriptState) {
    foreach ($hash in $scriptState.PSObject.Properties.Name) {
        $entry = $scriptState.$hash
        # Match Windows scripts only: 014, 015, 016
        if ($entry.name -match "windows.*0(14|15|16)_(install_proton_pass|login_proton_pass|modify_ssh_config_include)") {
            $scriptsFoundInScriptState++
            Write-Host "  Clearing scriptState for: $($entry.name) (hash: $($hash.Substring(0,8))...)" -ForegroundColor Gray
            $result = chezmoi state delete --bucket=scriptState --key=$hash 2>&1
            if ($LASTEXITCODE -eq 0) {
                $deletedScripts++
            } else {
                Write-Host "    Warning: Failed to delete from scriptState ($result)" -ForegroundColor Yellow
            }
        }
    }
}

# Second, clear from entryState bucket (tracks script files themselves)
$entryState = $stateDump.entryState
$scriptsFoundInEntryState = 0
if ($entryState) {
    foreach ($entryPath in $entryState.PSObject.Properties.Name) {
        # Match Windows script paths in entryState
        if ($entryPath -match "chezmoiscripts.*windows.*0(14|15|16)_(install_proton_pass|login_proton_pass|modify_ssh_config_include)") {
            $scriptsFoundInEntryState++
            Write-Host "  Clearing entryState for: $entryPath" -ForegroundColor Gray
            $result = chezmoi state delete --bucket=entryState --key=$entryPath 2>&1
            if ($LASTEXITCODE -eq 0) {
                $deletedScripts++
            } else {
                Write-Host "    Warning: Failed to delete from entryState ($result)" -ForegroundColor Yellow
            }
        }
    }
}

if ($scriptsFoundInScriptState -eq 0 -and $scriptsFoundInEntryState -eq 0) {
    Write-Host "  No Proton Pass script state entries found" -ForegroundColor Gray
    Write-Host "  (Searched for: .chezmoiscripts/windows/*014|015|016*)" -ForegroundColor DarkGray
}

# Delete file state entries for SSH keys
Write-Host "Clearing file state tracking..." -ForegroundColor Yellow

# Get all SSH key entries from state (handles both Unix and Windows paths)
$sshKeyPattern = "work_ssh_2025_dec"
$entriesToDelete = @()

foreach ($entryPath in $stateDump.entryState.PSObject.Properties.Name) {
    if ($entryPath -match $sshKeyPattern) {
        $entriesToDelete += $entryPath
    }
}

if ($entriesToDelete.Count -eq 0) {
    Write-Host "  No SSH key state entries found" -ForegroundColor Gray
} else {
    foreach ($entryKey in $entriesToDelete) {
        Write-Host "  Clearing state for: $entryKey" -ForegroundColor Gray
        chezmoi state delete --bucket=entryState --key=$entryKey 2>$null
        if ($LASTEXITCODE -eq 0) {
            $deletedFiles++
        }
    }
}

Write-Host ""
Write-Host "State tracking cleared successfully!" -ForegroundColor Green
Write-Host "  Script state entries cleared: $deletedScripts" -ForegroundColor Green
Write-Host "  File state entries cleared: $deletedFiles" -ForegroundColor Green
Write-Host ""

# Prompt or auto-apply
if ($Apply) {
    Write-Host "Running 'chezmoi apply'..." -ForegroundColor Cyan
    chezmoi apply
} else {
    Write-Host "To re-apply Proton Pass configuration, run:" -ForegroundColor Yellow
    Write-Host "  chezmoi apply" -ForegroundColor White
    Write-Host ""
    $response = Read-Host "Would you like to run 'chezmoi apply' now? (y/N)"
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host ""
        Write-Host "Running 'chezmoi apply'..." -ForegroundColor Cyan
        chezmoi apply
    }
}
