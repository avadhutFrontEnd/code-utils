#Requires -Version 5.1

param(
    [string[]]$ScanPaths = @("$env:USERPROFILE"),
    [string]$OutputFile = "$env:USERPROFILE\Desktop\markdown-files-report.md",
    [string[]]$ExcludeFolders = @(
        ".git",
        "node_modules",
        ".next",
        ".nuget",
        "dist",
        "build",
        "AppData",
        ".cursor",
        ".vscode"
    ),
    [int]$MaxTreeLinesPerRoot = 0,
    [int]$MaxChildrenPerNode = 0
)

$ErrorActionPreference = "SilentlyContinue"

function Test-IsExcludedPath {
    param(
        [string]$Path,
        [string[]]$Excluded
    )

    foreach ($name in $Excluded) {
        if ($Path -match "(^|[\\/])$([regex]::Escape($name))([\\/]|$)") {
            return $true
        }
    }
    return $false
}

function New-TreeNode {
    return [ordered]@{
        IsFile   = $false
        Children = [ordered]@{}
    }
}

function Add-RelativePathToTree {
    param(
        [hashtable]$RootNode,
        [string[]]$Parts
    )

    $partsList = @($Parts)
    $current = $RootNode
    for ($i = 0; $i -lt $partsList.Count; $i++) {
        $part = [string]$partsList[$i]
        if (-not $current.Children.Contains($part)) {
            $current.Children[$part] = New-TreeNode
        }
        $child = $current.Children[$part]
        if ($i -eq $partsList.Count - 1) {
            $child.IsFile = $true
        }
        $current = $child
    }
}

function Get-SortedChildNames {
    param([hashtable]$Node)

    $dirs = @()
    $files = @()
    foreach ($key in $Node.Children.Keys) {
        if ($Node.Children[$key].IsFile) {
            $files += $key
        } else {
            $dirs += $key
        }
    }
    $dirs = @($dirs | Sort-Object)
    $files = @($files | Sort-Object)
    return @($dirs + $files)
}

function Render-TreeRecursive {
    param(
        [hashtable]$Node,
        [string]$Prefix,
        [System.Collections.Generic.List[string]]$Lines,
        [ref]$LineCount,
        [int]$MaxLines,
        [int]$MaxChildren
    )

    if ($MaxLines -gt 0 -and $LineCount.Value -ge $MaxLines) { return }

    $children = @(Get-SortedChildNames -Node $Node)
    if (-not $children -or $children.Count -eq 0) { return }

    $totalChildren = $children.Count
    $takeCount = if ($MaxChildren -gt 0) { [Math]::Min($totalChildren, $MaxChildren) } else { $totalChildren }

    for ($i = 0; $i -lt $takeCount; $i++) {
        if ($MaxLines -gt 0 -and $LineCount.Value -ge $MaxLines) { return }

        $name = $children[$i]
        $childNode = $Node.Children[$name]
        $isLastVisible = ($i -eq $takeCount - 1) -and ($takeCount -eq $totalChildren)
        $connector = if ($isLastVisible) { "\-- " } else { "|-- " }
        $suffix = if ($childNode.IsFile) { "" } else { "/" }

        $Lines.Add("$Prefix$connector$name$suffix")
        $LineCount.Value++

        if (-not $childNode.IsFile) {
            $nextPrefix = if ($isLastVisible) { "$Prefix    " } else { "$Prefix|   " }
            Render-TreeRecursive -Node $childNode -Prefix $nextPrefix -Lines $Lines -LineCount $LineCount -MaxLines $MaxLines -MaxChildren $MaxChildren
        }
    }

    if ($totalChildren -gt $takeCount -and (($MaxLines -le 0) -or ($LineCount.Value -lt $MaxLines))) {
        $remaining = $totalChildren - $takeCount
        $Lines.Add("$Prefix\-- ... (+$remaining more)")
        $LineCount.Value++
    }
}

Write-Host ""
Write-Host "=== Markdown File Scanner ===" -ForegroundColor Cyan
Write-Host "Scanning paths: $($ScanPaths -join ', ')" -ForegroundColor Yellow
Write-Host ""

$groups = [System.Collections.Generic.Dictionary[string, object]]::new()
$totalMdFiles = 0

foreach ($scanRoot in $ScanPaths) {
    if (-not (Test-Path $scanRoot)) { continue }

    Write-Host "  Scanning: $scanRoot" -ForegroundColor Gray

    $raw = cmd /c "dir /s /b `"$scanRoot\*.md`" 2>nul"
    if (-not $raw) { continue }

    $files = $raw -split "`r?`n" | Where-Object { $_.Trim() -ne "" }

    foreach ($filePath in $files) {
        if (Test-IsExcludedPath -Path $filePath -Excluded $ExcludeFolders) { continue }
        if (-not (Test-Path $filePath)) { continue }

        $normalizedRoot = $scanRoot.TrimEnd('\')
        if (-not $filePath.StartsWith($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)) { continue }

        $relative = $filePath.Substring($normalizedRoot.Length).TrimStart('\')
        if ([string]::IsNullOrWhiteSpace($relative)) { continue }

        $parts = @($relative -split '[\\/]')
        if ($parts.Count -eq 0) { continue }

        if ($parts.Count -eq 1) {
            $rootPath = $normalizedRoot
            $treeParts = @($parts[0])
        } else {
            $rootPath = Join-Path $normalizedRoot $parts[0]
            $treeParts = @($parts[1..($parts.Count - 1)])
        }

        $groupKey = $rootPath.ToLowerInvariant()

        if (-not $groups.ContainsKey($groupKey)) {
            $groups[$groupKey] = [PSCustomObject]@{
                RootPath  = $rootPath
                FileCount = 0
                Tree      = New-TreeNode
            }
        }

        $group = $groups[$groupKey]
        Add-RelativePathToTree -RootNode $group.Tree -Parts $treeParts
        $group.FileCount++
        $totalMdFiles++
    }
}

$rootGroups = $groups.Values | Sort-Object RootPath

$md = [System.Text.StringBuilder]::new()
[void]$md.AppendLine("# Markdown Files Location Report")
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
[void]$md.AppendLine("| Root folders containing `.md` files | **$($rootGroups.Count)** |")
[void]$md.AppendLine("| Total `.md` files found | **$totalMdFiles** |")
[void]$md.AppendLine("")
[void]$md.AppendLine("> Tree output is full by default. Set `-MaxTreeLinesPerRoot` or `-MaxChildrenPerNode` to limit size.")
[void]$md.AppendLine("")
[void]$md.AppendLine("---")
[void]$md.AppendLine("")
[void]$md.AppendLine("## Root Folders with Markdown Files")
[void]$md.AppendLine("")

$idx = 1
foreach ($group in $rootGroups) {
    [void]$md.AppendLine("### $idx. $([System.IO.Path]::GetFileName($group.RootPath))")
    [void]$md.AppendLine("")
    [void]$md.AppendLine("| Detail | Value |")
    [void]$md.AppendLine("|---|---|")
    [void]$md.AppendLine("| Root Path | ``$($group.RootPath)`` |")
    [void]$md.AppendLine("| Markdown Files | $($group.FileCount) |")
    [void]$md.AppendLine("")
    [void]$md.AppendLine('```text')
    [void]$md.AppendLine($group.RootPath)

    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lineCount = 0
    Render-TreeRecursive -Node $group.Tree -Prefix "" -Lines $lines -LineCount ([ref]$lineCount) -MaxLines $MaxTreeLinesPerRoot -MaxChildren $MaxChildrenPerNode

    foreach ($line in $lines) {
        [void]$md.AppendLine($line)
    }
    if ($MaxTreeLinesPerRoot -gt 0 -and $lineCount -ge $MaxTreeLinesPerRoot) {
        [void]$md.AppendLine("... (tree truncated)")
    }
    [void]$md.AppendLine('```')
    [void]$md.AppendLine("")
    $idx++
}

[void]$md.AppendLine("---")
[void]$md.AppendLine("")
[void]$md.AppendLine("*End of report.*")

$md.ToString() | Out-File -FilePath $OutputFile -Encoding utf8 -Force

Write-Host ""
Write-Host "=== Report Saved ===" -ForegroundColor Cyan
Write-Host "  File: $OutputFile" -ForegroundColor Green
Write-Host "  Root folders: $($rootGroups.Count), Markdown files: $totalMdFiles" -ForegroundColor Yellow
Write-Host ""
