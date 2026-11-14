param(
    [string]$Destination = (Join-Path (Split-Path $PSScriptRoot -Parent) '.work/aerial-tv'),
    [string]$SourceRepository
)

$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$taskLock = Get-Content -LiteralPath (Join-Path $taskRoot 'upstream.lock.json') -Raw | ConvertFrom-Json
$taskPatch = Join-Path $taskRoot $taskLock.patch
if ((Get-FileHash -LiteralPath $taskPatch -Algorithm SHA256).Hash.ToLowerInvariant() -ne $taskLock.patch_sha256) {
    throw 'Patch checksum mismatch.'
}
$taskDestination = [IO.Path]::GetFullPath($Destination)
if ((Test-Path -LiteralPath $taskDestination) -and (Get-ChildItem -LiteralPath $taskDestination -Force)) {
    throw 'Destination must be empty. Existing files have not been changed.'
}
function Invoke-TaskGit([string[]]$GitArgs) {
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) { throw 'Git command failed; inspect the output above.' }
}
New-Item -ItemType Directory -Path $taskDestination -Force | Out-Null
Invoke-TaskGit @('init', $taskDestination)
Invoke-TaskGit @('-C', $taskDestination, 'remote', 'add', 'upstream', $taskLock.repository)
$taskSource = if ($SourceRepository) { [IO.Path]::GetFullPath($SourceRepository) } else { $taskLock.repository }
Invoke-TaskGit @('-C', $taskDestination, 'fetch', '--depth=1', $taskSource, $taskLock.commit)
Invoke-TaskGit @('-C', $taskDestination, 'checkout', '--detach', 'FETCH_HEAD')
$taskHead = (& git -C $taskDestination rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $taskHead -ne $taskLock.commit) { throw 'Unexpected upstream commit.' }
Invoke-TaskGit @('-C', $taskDestination, 'apply', '--check', $taskPatch)
Invoke-TaskGit @('-C', $taskDestination, 'apply', $taskPatch)
Write-Output "Prepared Aerial sources: $taskDestination"
Write-Output 'No TV settings were changed. Configure your own local SDK and release signing key before building.'
