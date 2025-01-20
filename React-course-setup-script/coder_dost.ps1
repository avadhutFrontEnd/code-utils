# Store original location
$originalLocation = Get-Location

# Define paths
$courseDir = "C:\Users\Avadhut\Desktop\Courses\coderDost"
$notesDir = "C:\Users\Avadhut\Desktop\Notes\4. React_JS - Notes\React Notes - coderDost"
$reactProjectDir = "C:\Users\Avadhut\Desktop\React folder\coderDost"
$obsidianPath = "C:\Users\Avadhut\AppData\Local\Obsidian\Obsidian.exe"
$potPlayerPath = "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"

# Task 1: Play specific React tutorial video in PotPlayer
$videoPath = Join-Path $courseDir "10-Hour React Tutorial 2023 - Zero to Advanced _ Learn React JS in Hindi.mp4"
if (Test-Path $videoPath) {
    if (Test-Path $potPlayerPath) {
        Start-Process -FilePath $potPlayerPath -ArgumentList "`"$videoPath`""
        Write-Host "Playing React tutorial video in PotPlayer"
    } else {
        Write-Host "PotPlayer not found at $potPlayerPath. Please update the path."
    }
} else {
    Write-Host "Video file not found at $videoPath"
}

# Task 2: Open React notes folder
if (Test-Path $notesDir) {
    Start-Process "explorer.exe" -ArgumentList "`"$notesDir`""
    Write-Host "Opened React notes folder"
} else {
    Write-Host "Notes directory not found at $notesDir"
}

# Task 3: Open React project folder
if (Test-Path $reactProjectDir) {
    Start-Process "explorer.exe" -ArgumentList "`"$reactProjectDir`""
    Write-Host "Opened React project folder"
} else {
    Write-Host "React project directory not found at $reactProjectDir"
}

# Task 4: Open Obsidian
if (Test-Path $obsidianPath) {
    Start-Process $obsidianPath
    Write-Host "Launched Obsidian successfully"
} else {
    Write-Host "Obsidian not found at $obsidianPath"
}

# Task 5: Open course folder
if (Test-Path $courseDir) {
    Start-Process "explorer.exe" -ArgumentList "`"$courseDir`""
    Write-Host "Opened React notes folder"
} else {
    Write-Host "Notes directory not found at $courseDir"
}

# Return to original location
Set-Location $originalLocation
Write-Host "Script completed. PowerShell location restored to: $originalLocation"