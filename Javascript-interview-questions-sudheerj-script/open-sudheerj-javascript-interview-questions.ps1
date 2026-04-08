# Opens Sudheerj JavaScript interview questions workflow:
# - VS Code: Telegram-export markdown file
# - Cursor: JavaScript notes workspace (same folder as typical JS terminal cwd)
# - Obsidian
# - Chrome: sudheerj/javascript-interview-questions README (Table of Contents)
#
# Chrome profile: same pattern as java-script\UltimateJavaScriptPart_1_Fundamentals.ps1
# Change $selectedProfile if your GitHub login lives in another Chrome profile folder.

$originalLocation = Get-Location

# --- Paths (edit if your machine differs) ---
$telegramMdPath =
    "C:\Users\Avadhut\Downloads\Telegram Desktop\sudheerjjavascript interview questions.md"

$javascriptNotesWorkspace =
    "C:\Users\Avadhut\Desktop\OfficeDataGDriveSync\Obsidean\Avadhut Notes FolderSync\Avadhut Notes Google Drive\1. Web Development\3. JavaScript"

$sudheerjReadmeUrl =
    "https://github.com/sudheerj/javascript-interview-questions?tab=readme-ov-file#table-of-contents"

# Match UltimateJavaScriptPart_1_Fundamentals.ps1 / other course scripts (Profile 4).
$selectedProfile = "Profile 4"

# --- Validate paths ---
if (-not (Test-Path -LiteralPath $telegramMdPath)) {
    Write-Warning "Telegram markdown not found (fix filename/path): $telegramMdPath"
}
if (-not (Test-Path -LiteralPath $javascriptNotesWorkspace)) {
    Write-Warning "JavaScript workspace not found: $javascriptNotesWorkspace"
}

# --- VS Code: open the Telegram .md file ---
$codeExe = "${env:ProgramFiles}\Microsoft VS Code\Code.exe"
if (Get-Command code -ErrorAction SilentlyContinue) {
    Start-Process code -ArgumentList "`"$telegramMdPath`""
    Write-Host "VS Code: opened file (PATH: code)"
} elseif (Test-Path -LiteralPath $codeExe) {
    Start-Process -FilePath $codeExe -ArgumentList "`"$telegramMdPath`""
    Write-Host "VS Code: opened file ($codeExe)"
} else {
    Write-Host "VS Code not found. Install VS Code or add 'code' to PATH."
}

# --- Cursor: JavaScript notes folder (workspace) ---
$cursorExe = "$env:LOCALAPPDATA\Programs\cursor\Cursor.exe"
if (Get-Command cursor -ErrorAction SilentlyContinue) {
    Start-Process cursor -ArgumentList "`"$javascriptNotesWorkspace`""
    Write-Host "Cursor: JavaScript notes workspace (PATH)"
} elseif (Test-Path -LiteralPath $cursorExe) {
    Start-Process -FilePath $cursorExe -ArgumentList "`"$javascriptNotesWorkspace`""
    Write-Host "Cursor: JavaScript notes workspace ($cursorExe)"
} else {
    Write-Host "Cursor not found. Install Cursor and add 'cursor' to PATH, or: $cursorExe"
}

# --- Obsidian ---
$obsidianPath = "$env:LOCALAPPDATA\Obsidian\Obsidian.exe"
if (Test-Path -LiteralPath $obsidianPath) {
    Start-Process -FilePath $obsidianPath
    Write-Host "Obsidian launched."
} else {
    Write-Host "Obsidian not found at $obsidianPath - update if installed elsewhere."
}

# --- Chrome: profile + README URL (same helper as UltimateJavaScriptPart_1_Fundamentals.ps1) ---
function Open-ChromeWithProfile {
    param (
        [string]$Profile,
        [string[]]$Urls
    )
    $chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if (-not (Test-Path -LiteralPath $chromeExe)) {
        Write-Warning "Chrome not found at $chromeExe"
        return
    }
    $args = @("--profile-directory=`"$Profile`"") + $Urls
    Start-Process $chromeExe -ArgumentList $args
}

Open-ChromeWithProfile -Profile $selectedProfile -Urls @($sudheerjReadmeUrl)
Write-Host "Chrome: $sudheerjReadmeUrl (profile: $selectedProfile)"

Set-Location $originalLocation
Write-Host "Done. PowerShell cwd: $originalLocation"
