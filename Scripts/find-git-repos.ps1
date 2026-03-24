#Requires -Version 5.1

param(
    [string[]]$ScanPaths = @("$env:USERPROFILE"),
    [string]$OutputFile = "$env:USERPROFILE\Desktop\git-repos-report.md"
)

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "=== Git Repository Scanner ===" -ForegroundColor Cyan
Write-Host "Scanning paths: $($ScanPaths -join ', ')" -ForegroundColor Yellow
Write-Host "Phase 1: Fast directory scan (this is quick)..." -ForegroundColor Yellow
Write-Host ""

# Phase 1 - use cmd /c dir which is 10-50x faster than Get-ChildItem -Recurse
$gitDirs = [System.Collections.Generic.List[string]]::new()

foreach ($root in $ScanPaths) {
    if (-not (Test-Path $root)) { continue }
    Write-Host "  Scanning: $root" -ForegroundColor Gray

    $raw = cmd /c "dir /s /b /ad `"$root\.git`" 2>nul"
    if ($raw) {
        $lines = $raw -split "`r?`n" | Where-Object { $_.Trim() -ne '' }
        foreach ($line in $lines) {
            $skip = $false
            foreach ($excl in @("node_modules", ".nuget", "AppData", "scoop", ".cargo", ".rustup")) {
                if ($line -match [regex]::Escape($excl)) { $skip = $true; break }
            }
            if (-not $skip) { $gitDirs.Add($line) }
        }
    }
}

Write-Host ""
Write-Host "Found $($gitDirs.Count) repositories." -ForegroundColor Green
Write-Host "Phase 2: Gathering git details..." -ForegroundColor Yellow
Write-Host ""

$repos = [System.Collections.Generic.List[PSCustomObject]]::new()

foreach ($gitDir in $gitDirs) {
    $repoPath = Split-Path $gitDir -Parent
    $repoName = Split-Path $repoPath -Leaf

    Push-Location $repoPath

    $branch       = git rev-parse --abbrev-ref HEAD 2>$null
    $remoteUrl    = git remote get-url origin 2>$null
    $lastCommit   = git log -1 --format="%h - %s (%ar)" 2>$null
    $commitCount  = git rev-list --count HEAD 2>$null
    $statusOutput = git status --porcelain 2>$null
    $stashCount   = (git stash list 2>$null | Measure-Object).Count

    $isDirty      = ($statusOutput | Measure-Object).Count -gt 0
    $untrackedCnt = ($statusOutput | Where-Object { $_ -match '^\?\?' } | Measure-Object).Count
    $modifiedCnt  = ($statusOutput | Where-Object { $_ -match '^ ?M' } | Measure-Object).Count
    $stagedCnt    = ($statusOutput | Where-Object { $_ -match '^[MADRC]' } | Measure-Object).Count

    $hasRemote = [bool]$remoteUrl
    $status = if ($isDirty) { "Dirty" } else { "Clean" }

    Pop-Location

    $repos.Add([PSCustomObject]@{
        Name         = $repoName
        Path         = $repoPath
        Branch       = if ($branch) { $branch } else { "N/A" }
        Remote       = if ($remoteUrl) { $remoteUrl } else { "No remote" }
        HasRemote    = $hasRemote
        LastCommit   = if ($lastCommit) { $lastCommit } else { "No commits" }
        CommitCount  = if ($commitCount) { [int]$commitCount } else { 0 }
        Status       = $status
        Untracked    = $untrackedCnt
        Modified     = $modifiedCnt
        Staged       = $stagedCnt
        StashCount   = $stashCount
    })

    $icon = if ($isDirty) { "[!]" } else { "[OK]" }
    $color = if ($isDirty) { "Red" } else { "Green" }
    Write-Host "  $icon $repoName ($branch) - $status" -ForegroundColor $color
}

# Stats
$totalRepos   = $repos.Count
$dirtyRepos   = ($repos | Where-Object { $_.Status -eq "Dirty" }).Count
$cleanRepos   = $totalRepos - $dirtyRepos
$noRemote     = ($repos | Where-Object { -not $_.HasRemote }).Count
$totalCommits = ($repos | Measure-Object -Property CommitCount -Sum).Sum

# Build markdown report
$md = [System.Text.StringBuilder]::new()

[void]$md.AppendLine("# Git Repositories Report")
[void]$md.AppendLine("")
[void]$md.AppendLine("> **Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$md.AppendLine("> **Machine:** $env:COMPUTERNAME")
[void]$md.AppendLine("> **Scanned:** $($ScanPaths -join ', ')")
[void]$md.AppendLine("")
[void]$md.AppendLine("---")
[void]$md.AppendLine("")
[void]$md.AppendLine("## Summary")
[void]$md.AppendLine("")
[void]$md.AppendLine("| Metric | Count |")
[void]$md.AppendLine("|---|---|")
[void]$md.AppendLine("| Total Repositories | **$totalRepos** |")
[void]$md.AppendLine("| Clean (nothing to commit) | $cleanRepos |")
[void]$md.AppendLine("| Dirty (uncommitted changes) | **$dirtyRepos** |")
[void]$md.AppendLine("| No Remote Configured | **$noRemote** |")
[void]$md.AppendLine("| Total Commits (all repos) | $totalCommits |")
[void]$md.AppendLine("")

if ($dirtyRepos -gt 0 -or $noRemote -gt 0) {
    [void]$md.AppendLine("### Repos That Need Attention")
    [void]$md.AppendLine("")
    foreach ($r in $repos) {
        if ($r.Status -eq "Dirty" -or -not $r.HasRemote) {
            $warnings = @()
            if ($r.Status -eq "Dirty")  { $warnings += "uncommitted changes" }
            if (-not $r.HasRemote)       { $warnings += "no remote" }
            $warnText = $warnings -join ', '
            [void]$md.AppendLine("- **$($r.Name)** -- $warnText -- ``$($r.Path)``")
        }
    }
    [void]$md.AppendLine("")
}

[void]$md.AppendLine("---")
[void]$md.AppendLine("")
[void]$md.AppendLine("## All Repositories")
[void]$md.AppendLine("")

$index = 1
foreach ($r in ($repos | Sort-Object Name)) {
    if ($r.Status -eq "Dirty") { $statusBadge = "DIRTY" } else { $statusBadge = "CLEAN" }
    if ($r.HasRemote) { $remoteBadge = "Yes" } else { $remoteBadge = "No" }

    [void]$md.AppendLine("### $index. $($r.Name)")
    [void]$md.AppendLine("")
    [void]$md.AppendLine("| Detail | Value |")
    [void]$md.AppendLine("|---|---|")
    [void]$md.AppendLine("| Path | ``$($r.Path)`` |")
    [void]$md.AppendLine("| Branch | ``$($r.Branch)`` |")
    [void]$md.AppendLine("| Status | $statusBadge |")
    [void]$md.AppendLine("| Has Remote | $remoteBadge |")
    if ($r.HasRemote) {
        [void]$md.AppendLine("| Remote URL | ``$($r.Remote)`` |")
    }
    [void]$md.AppendLine("| Last Commit | $($r.LastCommit) |")
    [void]$md.AppendLine("| Total Commits | $($r.CommitCount) |")
    if ($r.Status -eq "Dirty") {
        [void]$md.AppendLine("| Untracked Files | $($r.Untracked) |")
        [void]$md.AppendLine("| Modified Files | $($r.Modified) |")
        [void]$md.AppendLine("| Staged Files | $($r.Staged) |")
    }
    if ($r.StashCount -gt 0) {
        [void]$md.AppendLine("| Stashes | $($r.StashCount) |")
    }
    [void]$md.AppendLine("")
    $index++
}

[void]$md.AppendLine("---")
[void]$md.AppendLine("")
[void]$md.AppendLine("*End of report.*")

$md.ToString() | Out-File -FilePath $OutputFile -Encoding utf8 -Force

Write-Host ""
Write-Host "=== Report Saved ===" -ForegroundColor Cyan
Write-Host "  File: $OutputFile" -ForegroundColor Green
Write-Host "  Total: $totalRepos repos ($dirtyRepos dirty, $noRemote without remote)" -ForegroundColor Yellow
Write-Host ""
