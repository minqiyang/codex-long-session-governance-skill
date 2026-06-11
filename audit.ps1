$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillPath = Join-Path $RepoRoot 'SKILL.md'
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
    param([Parameter(Mandatory=$true)][string]$Message)
    $Failures.Add($Message) | Out-Null
}

function Get-RelativePath {
    param(
        [Parameter(Mandatory=$true)][string]$BasePath,
        [Parameter(Mandatory=$true)][string]$FullPath
    )

    return [System.IO.Path]::GetRelativePath($BasePath, $FullPath)
}

if (-not (Test-Path -LiteralPath $SkillPath)) {
    Add-Failure 'SKILL.md is missing.'
} else {
    $skillText = Get-Content -LiteralPath $SkillPath -Raw

    if ($skillText -notmatch '(?s)^---\s*\r?\n(.*?)\r?\n---') {
        Add-Failure 'SKILL.md frontmatter is missing or malformed.'
    } else {
        $frontmatter = $Matches[1]
        if ($frontmatter -notmatch '(?m)^name:\s*\S+') {
            Add-Failure 'SKILL.md frontmatter is missing name.'
        }
        if ($frontmatter -notmatch '(?m)^description:\s*\S+') {
            Add-Failure 'SKILL.md frontmatter is missing description.'
        } else {
            $descriptionLine = ($frontmatter -split "`r?`n" | Where-Object { $_ -match '^description:\s*' } | Select-Object -First 1)
            $description = $descriptionLine -replace '^description:\s*', ''
            $requiredDescriptionTerms = @(
                'Codex long session',
                'context budget',
                'byte cap',
                'command output protection',
                'needle map',
                'living handoff',
                'retrieval policy',
                'repo workflow governance',
                'PR gate',
                'truncation recovery',
                'token budget'
            )

            foreach ($term in $requiredDescriptionTerms) {
                if ($description.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
                    Add-Failure "Description is missing required term: $term"
                }
            }
        }
    }
}

$markdownFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -Force -File -Filter '*.md' |
    Where-Object { $_.FullName -notmatch '\\\.git\\' }

foreach ($file in $markdownFiles) {
    $fenceCount = (Select-String -LiteralPath $file.FullName -Pattern '^\s*```' | Measure-Object).Count
    if (($fenceCount % 2) -ne 0) {
        Add-Failure "Markdown code fences are not closed in $(Get-RelativePath -BasePath $RepoRoot -FullPath $file.FullName)."
    }
}

$sensitiveFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -Force -File |
    Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        (
            $_.Name -ieq '.env' -or
            $_.Name -like '*secret*' -or
            $_.Name -like '*token*' -or
            $_.Name -like '*credential*' -or
            $_.Name -ieq 'config.toml'
        )
    } |
    ForEach-Object { Get-RelativePath -BasePath $RepoRoot -FullPath $_.FullName }

if ($sensitiveFiles) {
    Add-Failure ("Sensitive-looking file(s) found: " + (($sensitiveFiles | Sort-Object -Unique) -join ', '))
}

$personalPathPatterns = @(
    ('C:' + '\Users\MINQI'),
    ('D:' + '\Users\MINQI')
)

$textFiles = Get-ChildItem -LiteralPath $RepoRoot -Recurse -Force -File |
    Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.Name -notlike '*secret*' -and
        $_.Name -notlike '*token*' -and
        $_.Name -notlike '*credential*' -and
        $_.Name -ine '.env' -and
        $_.Name -ine 'config.toml'
    }

foreach ($pattern in $personalPathPatterns) {
    $hits = Select-String -Path $textFiles.FullName -SimpleMatch -Pattern $pattern -ErrorAction SilentlyContinue
    foreach ($hit in $hits) {
        Add-Failure "Hardcoded personal path found in $(Get-RelativePath -BasePath $RepoRoot -FullPath $hit.Path):$($hit.LineNumber)"
    }
}

if ($Failures.Count -eq 0) {
    Write-Host 'PASS: audit completed successfully.'
    Write-Host 'Checked: SKILL.md, frontmatter, description terms, Markdown fences, sensitive filenames, hardcoded personal paths.'
    exit 0
}

Write-Host 'FAIL: audit found issues.'
foreach ($failure in $Failures) {
    Write-Host " - $failure"
}
exit 1
