# Opens DSA (Code with Mosh) course folders in Explorer, then Cursor (notes), Obsidian, and Monosnap.
# Prompt: Topic 1, 2, or 3 - maps to video + subtitles folders below.
# Optional: -Topic 1|2|3 (non-interactive; for scripts and tests).

param(
    [ValidateSet("1", "2", "3")]
    [string]$Topic
)

$ErrorActionPreference = "Stop"
$originalLocation = Get-Location

$courseBase = "C:\Users\Avadhut\Desktop\Courses\code with mosh\5) Data Structure"

$topicPaths = @{
    "1" = @{
        Videos    = Join-Path $courseBase "Data Structures and Algorithms Part 1"
        Subtitles = Join-Path $courseBase "Data Structures and Algorithms Part 1\Part 1-20260326T171912Z-3-001\Part 1"
    }
    "2" = @{
        Videos    = Join-Path $courseBase "Data Structures and Algorithms Part 2"
        Subtitles = Join-Path $courseBase "Data Structures and Algorithms Part 2\Part 2-20260326T171913Z-3-001\Part 2\subtitles-folders-part2"
    }
    "3" = @{
        Videos    = Join-Path $courseBase "Data Structures and Algorithms Part 3"
        Subtitles = Join-Path $courseBase "Data Structures and Algorithms Part 3\subtitles-folders-part3"
    }
}

$cursorNotesPath = "C:\Users\Avadhut\Desktop\OfficeDataGDriveSync\Obsidean\Avadhut Notes FolderSync\Avadhut Notes Google Drive\0. Data Structure and Algorithum\Code with Mosh"
$cursorExe = "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe"
$obsidianPath = "$env:LOCALAPPDATA\Obsidian\Obsidian.exe"
$monosnapPath = "$env:LOCALAPPDATA\Monosnap\Monosnap.exe"

function Open-ExplorerFolder {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Warning "Path not found (create or fix path): $Path"
        return
    }
    Start-Process "explorer.exe" -ArgumentList "`"$Path`""
    Write-Host "Explorer: $Path"
}

Write-Host ""
Write-Host "DSA - Code with Mosh workspace"
if ($Topic) {
    $choice = $Topic
    Write-Host "Topic (non-interactive): $choice"
} else {
    Write-Host "Which topic? 1 = Part 1, 2 = Part 2, 3 = Part 3"
    $choice = Read-Host "Enter 1, 2, or 3"
    while ($choice -notin @("1", "2", "3")) {
        Write-Host "Invalid choice. Use 1, 2, or 3."
        $choice = Read-Host "Enter 1, 2, or 3"
    }
}

$t = $topicPaths[$choice]
Write-Host ""
Write-Host "Opening video folder and subtitles folder in File Explorer..."
Open-ExplorerFolder -Path $t.Videos
Open-ExplorerFolder -Path $t.Subtitles

if (-not (Test-Path -LiteralPath $cursorNotesPath)) {
    Write-Warning "Cursor notes path not found: $cursorNotesPath"
}

if (Get-Command cursor -ErrorAction SilentlyContinue) {
    Start-Process cursor -ArgumentList "`"$cursorNotesPath`""
    Write-Host "Cursor: DSA notes (cursor on PATH)"
} elseif (Test-Path -LiteralPath $cursorExe) {
    Start-Process -FilePath $cursorExe -ArgumentList "`"$cursorNotesPath`""
    Write-Host "Cursor: DSA notes ($cursorExe)"
} else {
    Write-Host "Cursor not found. Install Cursor and add 'cursor' to PATH, or install to: $cursorExe"
}

if (Test-Path -LiteralPath $obsidianPath) {
    Start-Process -FilePath $obsidianPath
    Write-Host "Obsidian launched."
} else {
    Write-Host "Obsidian not found at $obsidianPath - update if installed elsewhere."
}

if (Test-Path -LiteralPath $monosnapPath) {
    Start-Process -FilePath $monosnapPath
    Write-Host "Monosnap launched."
} else {
    Write-Host "Monosnap not found at $monosnapPath - update if installed elsewhere."
}

Set-Location $originalLocation
Write-Host ""
Write-Host "Done."
