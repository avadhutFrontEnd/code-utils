# Opens Tier 1 resume-builder + Tier 1 Companies notes in two separate Cursor windows (two workspaces), and Obsidian.
# Pattern matches React-course-setup-script / TypeScript Windows_scripts.

$originalLocation = Get-Location

$resumeBuilderPath =
    "C:\Users\Avadhut\Desktop\git\tier-1-company-projects\resume-builder"
$tier1CompaniesNotesPath =
    "C:\Users\Avadhut\Desktop\OfficeDataGDriveSync\Obsidean\Avadhut Notes FolderSync\Avadhut Notes Google Drive\1. Web Development\Tier 1 Companies Project"

foreach ($p in @($resumeBuilderPath, $tier1CompaniesNotesPath)) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Warning "Path not found (create or fix sync): $p"
    }
}

# Cursor - one window per folder (two workspaces), not multi-root
$cursorExe = "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe"
if (Get-Command cursor -ErrorAction SilentlyContinue) {
    Start-Process cursor -ArgumentList "`"$resumeBuilderPath`""
    Start-Process cursor -ArgumentList "`"$tier1CompaniesNotesPath`""
    Write-Host "Cursor: two windows - resume-builder, Tier 1 Companies Project (PATH)"
} elseif (Test-Path -LiteralPath $cursorExe) {
    Start-Process -FilePath $cursorExe -ArgumentList "`"$resumeBuilderPath`""
    Start-Process -FilePath $cursorExe -ArgumentList "`"$tier1CompaniesNotesPath`""
    Write-Host "Cursor: two windows - resume-builder, Tier 1 Companies Project ($cursorExe)"
} else {
    Write-Host "Cursor not found. Install Cursor and add 'cursor' to PATH, or install to default location: $cursorExe"
}

# Obsidian
$obsidianPath = "$env:LOCALAPPDATA\Obsidian\Obsidian.exe"
if (Test-Path -LiteralPath $obsidianPath) {
    Start-Process -FilePath $obsidianPath
    Write-Host "Obsidian launched."
} else {
    Write-Host "Obsidian not found at $obsidianPath - update if installed elsewhere."
}

Set-Location $originalLocation
Write-Host "Done. PowerShell cwd: $originalLocation"
