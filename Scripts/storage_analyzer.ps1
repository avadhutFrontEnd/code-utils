# Storage Analyzer Script for Windows
# Generates a detailed Markdown report of disk usage

# Output file
$outputFile = "storage_report.md"

Write-Host "Analyzing storage... This may take a few minutes." -ForegroundColor Cyan

# Start Markdown report
$report = @"
# 💾 Storage Analysis Report
**Generated on:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Computer:** $env:COMPUTERNAME

---

## 📊 Disk Overview

"@

# Get all drives
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 }

foreach ($drive in $drives) {
    $usedGB = [math]::Round($drive.Used / 1GB, 2)
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    $totalGB = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)
    $usedPercent = [math]::Round(($drive.Used / ($drive.Used + $drive.Free)) * 100, 1)
    
    $report += @"

### Drive $($drive.Name):
- **Total Size:** $totalGB GB
- **Used Space:** $usedGB GB ($usedPercent%)
- **Free Space:** $freeGB GB
- **Status:** $(if($usedPercent -gt 90){"⚠️ Critical"}elseif($usedPercent -gt 80){"⚠️ Warning"}else{"✅ Good"})

"@
}

$report += @"

---

## 📁 Top 20 Largest Folders in C:\

| # | Folder Path | Size (GB) | File Count |
|---|------------|-----------|------------|
"@

# Analyze C:\ drive folders (top level)
Write-Host "Scanning C:\ folders..." -ForegroundColor Yellow

$folders = Get-ChildItem -Path "C:\" -Directory -ErrorAction SilentlyContinue | 
    ForEach-Object {
        Write-Host "  Analyzing: $($_.Name)" -ForegroundColor Gray
        $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        $fileCount = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                      Measure-Object).Count
        
        [PSCustomObject]@{
            Path = $_.FullName
            SizeBytes = if($size){$size}else{0}
            SizeGB = [math]::Round($size / 1GB, 2)
            Files = $fileCount
        }
    } | Sort-Object SizeBytes -Descending | Select-Object -First 20

$counter = 1
foreach ($folder in $folders) {
    $report += "`n| $counter | ``$($folder.Path)`` | $($folder.SizeGB) | $($folder.Files) |"
    $counter++
}

$report += @"


---

## 📦 Common Space Consumers

### Windows Folders
"@

# Analyze specific Windows folders
$windowsFolders = @(
    "C:\Windows\Temp",
    "C:\Windows\SoftwareDistribution",
    "C:\Windows\Installer",
    "C:\Windows\Logs"
)

foreach ($folder in $windowsFolders) {
    if (Test-Path $folder) {
        $size = (Get-ChildItem -Path $folder -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($size / 1GB, 2)
        $report += "`n- **${folder}:** $sizeGB GB"
    }
}

$report += @"


### User Folders
"@

$userFolders = @(
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\AppData\Local\Temp"
)

foreach ($folder in $userFolders) {
    if (Test-Path $folder) {
        $size = (Get-ChildItem -Path $folder -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($size / 1GB, 2)
        $fileCount = (Get-ChildItem -Path $folder -Recurse -File -ErrorAction SilentlyContinue | 
                      Measure-Object).Count
        $report += "`n- **${folder}:** $sizeGB GB ($fileCount files)"
    }
}

$report += @"


---

## 🗑️ Temporary Files & Cache

"@

# Temp files analysis
$tempLocations = @{
    "Windows Temp" = "C:\Windows\Temp"
    "User Temp" = "$env:TEMP"
    "Browser Cache (Chrome)" = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
    "Browser Cache (Edge)" = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
    "Recycle Bin" = "C:\`$Recycle.Bin"
}

foreach ($location in $tempLocations.GetEnumerator()) {
    if (Test-Path $location.Value) {
        $size = (Get-ChildItem -Path $location.Value -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        $sizeGB = [math]::Round($size / 1GB, 2)
        $report += "`n- **$($location.Key):** $sizeGB GB"
    }
}

$report += @"


---

## 🎮 Programs & Applications

### Top 10 Largest Programs

"@

# Get installed programs from registry
$programs = @()

$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $registryPaths) {
    Get-ItemProperty $path -ErrorAction SilentlyContinue | 
        Where-Object { $_.DisplayName -and $_.EstimatedSize } | 
        ForEach-Object {
            $programs += [PSCustomObject]@{
                Name = $_.DisplayName
                SizeMB = [math]::Round($_.EstimatedSize / 1024, 2)
            }
        }
}

$topPrograms = $programs | Sort-Object SizeMB -Descending | Select-Object -First 10

$report += "`n| # | Program Name | Size (MB) |`n|---|-------------|-----------|"

$counter = 1
foreach ($prog in $topPrograms) {
    $report += "`n| $counter | $($prog.Name) | $($prog.SizeMB) |"
    $counter++
}

$report += @"


---

## 💡 Cleanup Recommendations

### Safe to Delete:
1. ✅ **Temp Files** - `C:\Windows\Temp` and `$env:TEMP`
2. ✅ **Browser Cache** - Clear from browser settings
3. ✅ **Recycle Bin** - Empty it
4. ✅ **Windows Update Cache** - Use Disk Cleanup tool
5. ✅ **Downloads Folder** - Review and delete old files

### Requires Caution:
1. ⚠️ **Program Files** - Only uninstall unused applications
2. ⚠️ **Windows.old** - Old Windows installation (safe after 30 days)
3. ⚠️ **AppData** - Some app data can be removed

### Commands to Clean:
``````powershell
# Clear Windows Temp
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clear User Temp
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# Run Disk Cleanup
cleanmgr /sageset:1
cleanmgr /sagerun:1
``````

---

## 📈 File Type Distribution (C:\Users)

"@

# Analyze file types in user directory
Write-Host "Analyzing file types..." -ForegroundColor Yellow

$fileTypes = Get-ChildItem -Path "$env:USERPROFILE" -Recurse -File -ErrorAction SilentlyContinue | 
    Group-Object Extension | 
    ForEach-Object {
        $totalSize = ($_.Group | Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{
            Extension = if($_.Name){"*$($_.Name)"}else{"No Extension"}
            Count = $_.Count
            SizeGB = [math]::Round($totalSize / 1GB, 2)
        }
    } | Sort-Object SizeGB -Descending | Select-Object -First 15

$report += "`n| Extension | File Count | Total Size (GB) |`n|-----------|------------|----------------|"

foreach ($type in $fileTypes) {
    $report += "`n| $($type.Extension) | $($type.Count) | $($type.SizeGB) |"
}

$report += @"


---

## 🔧 Additional Tools

### Built-in Windows Tools:
1. **Disk Cleanup**: Run `cleanmgr`
2. **Storage Sense**: Settings → System → Storage
3. **Uninstall Programs**: Control Panel → Programs and Features

### PowerShell Commands:
``````powershell
# Find large files (>1GB) in C:\
Get-ChildItem -Path "C:\" -Recurse -File -ErrorAction SilentlyContinue | 
    Where-Object { $_.Length -gt 1GB } | 
    Sort-Object Length -Descending | 
    Select-Object FullName, @{N="Size(GB)";E={[math]::Round($_.Length/1GB,2)}}
``````

---

**⚠️ Important:** Always review files before deletion. Create backups of important data.

**Generated by Storage Analyzer Script**
"@

# Save report to file
$report | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "`n✅ Report generated successfully!" -ForegroundColor Green
Write-Host "📄 File saved as: $outputFile" -ForegroundColor Cyan
Write-Host "`nOpening report..." -ForegroundColor Yellow

# Open the report
Start-Process notepad.exe $outputFile