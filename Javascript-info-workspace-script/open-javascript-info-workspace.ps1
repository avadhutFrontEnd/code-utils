# Opens javascript.info notes in Cursor (one workspace) and Obsidian.
# Pattern matches Resume-builder-workspace-script\open-resume-builder-workspace.ps1.

$originalLocation = Get-Location

$javascriptInfoNotesPath =
    "C:\Users\Avadhut\Desktop\OfficeDataGDriveSync\Obsidean\Avadhut Notes FolderSync\Avadhut Notes Google Drive\1. Web Development\3. JavaScript\Javascript-info"

if (-not (Test-Path -LiteralPath $javascriptInfoNotesPath)) {
    Write-Warning "Path not found (create or fix sync): $javascriptInfoNotesPath"
}

# Cursor - single window for notes folder
$cursorExe = "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe"
if (Get-Command cursor -ErrorAction SilentlyContinue) {
    Start-Process cursor -ArgumentList "`"$javascriptInfoNotesPath`""
    Write-Host "Cursor: Javascript-info notes (PATH)"
} elseif (Test-Path -LiteralPath $cursorExe) {
    Start-Process -FilePath $cursorExe -ArgumentList "`"$javascriptInfoNotesPath`""
    Write-Host "Cursor: Javascript-info notes ($cursorExe)"
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
