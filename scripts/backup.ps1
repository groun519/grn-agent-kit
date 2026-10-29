[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' })
)

$sourceRoot = Join-Path $CodexHome 'skills'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$destinationRoot = Join-Path $repositoryRoot 'skills'

if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
    throw "Codex skills directory does not exist: $sourceRoot"
}

New-Item -ItemType Directory -Path $destinationRoot -Force | Out-Null

$skills = Get-ChildItem -LiteralPath $sourceRoot -Directory -Filter 'grn-*'
if ($skills.Count -eq 0) {
    throw "No grn-* skills were found in $sourceRoot"
}

foreach ($skill in $skills) {
    $manifest = Join-Path $skill.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
        Write-Warning "Skipping directory without SKILL.md: $($skill.FullName)"
        continue
    }

    $destination = Join-Path $destinationRoot $skill.Name
    if ($PSCmdlet.ShouldProcess($destination, "Back up $($skill.Name)")) {
        New-Item -ItemType Directory -Path $destination -Force | Out-Null
        Get-ChildItem -LiteralPath $skill.FullName -Force |
            Copy-Item -Destination $destination -Recurse -Force
        Write-Output "Backed up $($skill.Name)"
    }
}
