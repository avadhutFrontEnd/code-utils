# Store original location
$originalLocation = Get-Location

# Define paths - Design Pattern course
$courseBase = "C:\Users\Avadhut\Desktop\Courses\code with mosh\16. Design Patterns\Design Patterns"
$subtitlesBase = "$courseBase\Subtitles"
$potPlayerPath = "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"
$chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$chromeUserDataDir = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$selectedProfile = "Profile 4"
$cursorNotesPath = "C:\Users\Avadhut\Desktop\OfficeDataGDriveSync\Obsidean\Avadhut Notes FolderSync\Avadhut Notes Google Drive\1. Web Development\14. CWM - The Ultimate Design Pattern Series"
$cursorPracticePath = "C:\Users\Avadhut\Desktop\git\design-patterns-practice"
$obsidianPath = "C:\Users\Avadhut\AppData\Local\Obsidian\Obsidian.exe"
$monosnapPath = "C:\Users\Avadhut\AppData\Local\Monosnap\Monosnap.exe"

# Part-specific paths
$partNames = @{
    "1" = "The Ultimate Design Patterns Part 1"
    "2" = "The Ultimate Design Patterns Part 2"
    "3" = "The Ultimate Design Patterns Part 3"
}

# Ask user which part to study
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Design Patterns Course Setup Script" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan
Write-Host "Which part would you like to study?"
Write-Host "  1. Part 1 - Behavioral Patterns (4h, 13 sections)"
Write-Host "  2. Part 2 - Structural Patterns (2h, 9 sections)"
Write-Host "  3. Part 3 - Creational Patterns (1h, 7 sections)"
Write-Host ""

do {
    $partChoice = Read-Host "Enter part number (1, 2, or 3)"
} while ($partChoice -notin @("1", "2", "3"))

$selectedPart = $partNames[$partChoice]
$courseRoot = "$courseBase\$selectedPart"
$subtitlesDir = "$subtitlesBase\$selectedPart"

Write-Host "`nSelected: $selectedPart" -ForegroundColor Green
Write-Host ""

# Function to open Chrome with a specific profile and URLs
function Open-ChromeWithProfile {
    param (
        [string]$ProfileName,
        [string[]]$Urls
    )
    $chromeArgs = @(
        "--user-data-dir=`"$chromeUserDataDir`"",
        "--profile-directory=`"$ProfileName`""
    ) + $Urls
    Start-Process $chromeExe -ArgumentList $chromeArgs
}

# Function to list videos in a directory
function Show-Videos {
    param([string]$directory)

    $videos = Get-ChildItem -Path $directory -Filter *.mp4 | Sort-Object Name
    if ($videos.Length -eq 0) {
        Write-Host "No MP4 files found in this directory."
        return $null
    }

    Write-Host "Available video files:`n"
    for ($i = 0; $i -lt $videos.Length; $i++) {
        Write-Host "$($i + 1). $($videos[$i].Name)"
    }
    return $videos
}

# Function to play video
function Play-Video {
    param([string]$videoPath)
    if (Test-Path $potPlayerPath) {
        Start-Process -FilePath $potPlayerPath -ArgumentList "`"$videoPath`""
        Write-Host "Playing video: $videoPath"
    } else {
        Write-Host "PotPlayer not found at $potPlayerPath. Please update the path."
    }
}

# Launch initial applications
# Open video folder and subtitles folder in Windows Explorer
Start-Process "explorer.exe" -ArgumentList "`"$courseRoot`""
if (Test-Path $subtitlesDir) {
    Start-Process "explorer.exe" -ArgumentList "`"$subtitlesDir`""
    Write-Host "Opened video folder and Subtitles in File Explorer"
} else {
    Write-Host "Opened video folder in File Explorer (Subtitles path not found: $subtitlesDir)"
}

# Open Chrome with selected profile and Claude AI
$urls = @(
    "https://claude.ai/new"
)
Open-ChromeWithProfile -ProfileName $selectedProfile -Urls $urls
Write-Host "Chrome launched with Claude AI new chat"

# Launch Obsidian
if (Test-Path $obsidianPath) {
    Start-Process $obsidianPath
    Write-Host "Obsidian launched successfully"
} else {
    Write-Host "Obsidian not found at $obsidianPath"
}

# Launch MonoSnap
if (Test-Path $monosnapPath) {
    Start-Process $monosnapPath
    Write-Host "MonoSnap launched successfully"
} else {
    Write-Host "MonoSnap not found at $monosnapPath"
}

# Open Cursor in Design Pattern course notes folder
if (Test-Path $cursorNotesPath) {
    Start-Process "cursor" -ArgumentList "`"$cursorNotesPath`""
    Write-Host "Cursor launched with folder: $cursorNotesPath"
} else {
    Write-Host "Cursor notes path not found: $cursorNotesPath"
}

# Open Cursor in practice repository workspace
if (Test-Path $cursorPracticePath) {
    Start-Process "cursor" -ArgumentList "`"$cursorPracticePath`""
    Write-Host "Cursor launched with folder: $cursorPracticePath"
} else {
    Write-Host "Cursor practice path not found: $cursorPracticePath"
}

Write-Host "`n--- All applications launched ---`n" -ForegroundColor Green

# Main navigation loop (start at course root)
$current_dir = $courseRoot

while ($true) {
    Write-Host "`nCurrent directory: $current_dir"
    Write-Host "Contents:"

    $items = Get-ChildItem $current_dir | Sort-Object Name
    for ($i = 0; $i -lt $items.Length; $i++) {
        Write-Host "$($i + 1). $($items[$i].Name)"
    }

    Write-Host "`nEnter a number to select an item, 'b' to go back, or 'q' to quit:"
    $choice = Read-Host

    switch -Regex ($choice) {
        '^q$' {
            Write-Host "Exiting script."
            Set-Location $originalLocation
            exit
        }
        '^b$' {
            if ($current_dir -ne $courseRoot) {
                $current_dir = Split-Path $current_dir -Parent
            } else {
                Write-Host "Already at the main directory."
            }
        }
        '^\d+$' {
            $selection = [int]$choice
            if ($selection -ge 1 -and $selection -le $items.Length) {
                $selected_item = $items[$selection - 1]

                if ($selected_item.PSIsContainer) {
                    $current_dir = $selected_item.FullName
                }
                elseif ($selected_item.Extension -eq ".mp4") {
                    do {
                        Play-Video $selected_item.FullName
                        Write-Host "`nVideo playback initiated. What would you like to do next?"
                        Write-Host "1. Play another video from this folder"
                        Write-Host "2. Go back to folder navigation"
                        $next_action = Read-Host "Enter your choice (1 or 2)"

                        if ($next_action -eq "1") {
                            $videos = Show-Videos $current_dir
                            if ($videos -ne $null) {
                                $video_choice = Read-Host "Enter the number of the video you want to play"
                                if ([int]$video_choice -ge 1 -and [int]$video_choice -le $videos.Length) {
                                    $selected_item = $videos[[int]$video_choice - 1]
                                } else {
                                    Write-Host "Invalid selection."
                                    break
                                }
                            } else {
                                break
                            }
                        } elseif ($next_action -eq "2") {
                            break
                        } else {
                            Write-Host "Invalid choice. Returning to folder navigation."
                            break
                        }
                    } while ($next_action -eq "1")
                }
                else {
                    Write-Host "Selected item is not a directory or MP4 file."
                }
            }
            else {
                Write-Host "Invalid selection. Please enter a number between 1 and $($items.Length)."
            }
        }
        default {
            Write-Host "Invalid input. Please try again."
        }
    }
}
