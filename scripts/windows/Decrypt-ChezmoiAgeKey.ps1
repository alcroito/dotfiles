<#
.SYNOPSIS
    Windows counterpart of scripts/unix/decrypt-chezmoi-age-key.sh. Same
    contract: get a current age identity into place, or warn and let the caller
    continue.
.DESCRIPTION
    Called from the [hooks.apply.pre] hook in .chezmoi.toml.tmpl and from
    run_onchange_before_005_decrypt_age_key. See the unix script's header for
    why only the hook lands in time.
.PARAMETER Recipient
    The configured age recipient. Resolved from chezmoi's template data when not
    passed.
#>
param(
  [string]$Recipient = ''
)

function Write-Unauthenticated {
  Write-Warning "mise and chezmoi will make unauthenticated GitHub API calls and may be rate limited"
  Write-Warning "run 'chezmoi apply' from an interactive shell to finish setup"
}

# CHEZMOI_EXECUTABLE is exported by chezmoi to the scripts it runs; install.ps1
# sets it explicitly. Neither caller can rely on chezmoi being on PATH.
$chezmoi = $env:CHEZMOI_EXECUTABLE
if ([string]::IsNullOrEmpty($chezmoi)) {
  $chezmoi = (Get-Command chezmoi -ErrorAction SilentlyContinue).Source
}
if ([string]::IsNullOrEmpty($chezmoi)) {
  $chezmoi = Join-Path $env:USERPROFILE '.local\bin\chezmoi.exe'
}
if (-not (Test-Path $chezmoi)) {
  Write-Warning "decrypt_age_key: no chezmoi executable found at $chezmoi, skipping age key decryption"
  Write-Unauthenticated
  exit 0
}

# The override exists so the missing-key and stale-key branches can be checked
# without breaking the real key.
$keyPath = $env:CHEZMOI_AGE_KEY_PATH
if ([string]::IsNullOrEmpty($keyPath)) {
  $keyPath = Join-Path $env:USERPROFILE '.config\chezmoi\key.txt'
}

# Both callers pass -Recipient, and both are only emitted when
# install_github_tokens is true, so this script does not re-check the flag. The
# fallback template deliberately contains no quotes: Windows PowerShell 5.1
# passes arguments to native commands in Legacy mode, which drops embedded
# double quotes, so a `hasKey . "x"` template would arrive at chezmoi malformed.
if ([string]::IsNullOrEmpty($Recipient)) {
  $Recipient = & $chezmoi execute-template '{{ .age_recipient }}' 2>$null
}

$sourceDir = $env:CHEZMOI_SOURCE_DIR
if ([string]::IsNullOrEmpty($sourceDir)) {
  $sourceDir = & $chezmoi source-path 2>$null
}
$sourceKey = Join-Path $sourceDir 'key.txt.age'

if ([string]::IsNullOrEmpty($Recipient)) {
  Write-Warning "decrypt_age_key: no age recipient configured, nothing to do"
  exit 0
}

if (-not (Test-Path $sourceKey)) {
  Write-Warning "decrypt_age_key: $sourceKey is missing"
  Write-Unauthenticated
  exit 0
}

if (Test-Path $keyPath) {
  $current = (& $chezmoi age-keygen -y $keyPath 2>$null)
  if ($current -eq $Recipient) {
    exit 0
  }
  Write-Warning "decrypt_age_key: local age key does not match the configured recipient, re-decrypting"
}

# No /dev/tty equivalent, so approximate it by asking whether input is redirected.
if ([Console]::IsInputRedirected) {
  Write-Warning "decrypt_age_key: no interactive console, skipping age key decryption"
  Write-Unauthenticated
  exit 0
}

New-Item -ItemType Directory -Force -Path (Split-Path $keyPath) | Out-Null

# chezmoi's own prompt is a bare "Enter passphrase:", so say what is being asked
# for before it appears.
Write-Output "decrypt_age_key: unlocking the chezmoi age identity, which decrypts the GitHub API token files"
Write-Output "decrypt_age_key: a wrong or refused passphrase is not fatal, the apply continues unauthenticated"
# Retried for the reason the unix script's loop explains: the hook is the only
# attempt that lands before .chezmoiignore is evaluated, so one mistyped
# passphrase would cost this apply every encrypted file.
$attempts = 3
for ($attempt = 1; $attempt -le $attempts; $attempt++) {
  & $chezmoi age decrypt --passphrase --output "$keyPath.new" $sourceKey
  if ($LASTEXITCODE -eq 0) {
    Move-Item -Force "$keyPath.new" $keyPath
    Write-Output "decrypt_age_key: age identity installed"
    exit 0
  }
  Remove-Item -Force -ErrorAction SilentlyContinue "$keyPath.new"
  if ($attempt -lt $attempts) {
    Write-Warning "decrypt_age_key: passphrase attempt $attempt of $attempts failed, trying again"
  }
}

Write-Warning "decrypt_age_key: age key decryption failed, keeping any existing key"
Write-Unauthenticated
exit 0
