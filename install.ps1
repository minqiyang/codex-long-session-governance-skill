param(
    [switch]$Install
)

$ErrorActionPreference = 'Stop'

$SkillName = 'codex-long-session-governance'
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Target = Join-Path $env:USERPROFILE ".agents\skills\$SkillName"
$ItemsToCopy = @('SKILL.md', 'references', 'assets')
$ForbiddenNamePatterns = @('.env', '*secret*', '*token*', '*credential*', 'config.toml')

function Get-RelativePath {
    param(
        [Parameter(Mandatory=$true)][string]$BasePath,
        [Parameter(Mandatory=$true)][string]$FullPath
    )

    $normalizedBase = $BasePath.TrimEnd('\') + '\'
    if ($FullPath.StartsWith($normalizedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $FullPath.Substring($normalizedBase.Length)
    }

    return $FullPath
}

$forbiddenFiles = foreach ($pattern in $ForbiddenNamePatterns) {
    Get-ChildItem -LiteralPath $RepoRoot -Recurse -Force -File -ErrorAction Stop |
        Where-Object { $_.Name -like $pattern } |
        ForEach-Object { Get-RelativePath -BasePath $RepoRoot -FullPath $_.FullName }
}

if ($forbiddenFiles) {
    Write-Error ("Refusing to install because sensitive-looking files are present: " + (($forbiddenFiles | Sort-Object -Unique) -join ', '))
}

$missing = foreach ($item in $ItemsToCopy) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $item))) {
        $item
    }
}

if ($missing) {
    Write-Error ("Missing required install item(s): " + ($missing -join ', '))
}

Write-Host "Skill: $SkillName"
Write-Host "Source: $RepoRoot"
Write-Host "Target: $Target"
Write-Host "Items: $($ItemsToCopy -join ', ')"

if (-not $Install) {
    Write-Host "Mode: dry-run"
    Write-Host "No files were copied. Re-run with -Install to install."
    return
}

$targetParent = Split-Path -Parent $Target
New-Item -ItemType Directory -Path $targetParent -Force | Out-Null

$backupPath = $null
if (Test-Path -LiteralPath $Target) {
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupRoot = Join-Path $targetParent 'backups'
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    $backupPath = Join-Path $backupRoot "$SkillName-$timestamp"
    Copy-Item -LiteralPath $Target -Destination $backupPath -Recurse -Force
    Remove-Item -LiteralPath $Target -Recurse -Force
}

New-Item -ItemType Directory -Path $Target -Force | Out-Null

foreach ($item in $ItemsToCopy) {
    $source = Join-Path $RepoRoot $item
    $destination = Join-Path $Target $item
    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
}

Write-Host "Mode: install"
Write-Host "Installed files:"
foreach ($item in $ItemsToCopy) {
    Write-Host " - $item"
}

if ($backupPath) {
    Write-Host "Backup: $backupPath"
} else {
    Write-Host "Backup: none needed"
}
