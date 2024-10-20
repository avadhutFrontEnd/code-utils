# Store original location
$originalLocation = Get-Location

# Define paths
$courseDir = "C:\Users\Avadhut\Desktop\Courses\code with mosh\Code with Mosh - The Ultimate HTML CSS Mastery Series  [Hacksnation.com]\Part1  [Hacksnation.com]"
$potPlayerPath = "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"
$chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$obsidianPath = "C:\Users\Avadhut\AppData\Local\Obsidian\Obsidian.exe"
$monosnapPath = "C:\Users\Avadhut\AppData\Local\Monosnap\Monosnap.exe"

# Function to open Chrome with a specific profile and URLs
function Open-ChromeWithProfile {
    param (
        [string]$Profile,
        [string[]]$Urls
    )
    $args = @("--profile-directory=`"$Profile`"") + $Urls
    Start-Process $chromeExe -ArgumentList $args
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
# Open Chrome with Profile 3 and specified URLs
$urls = @(
    "https://chatgpt.com/c/66ea74a3-8850-8006-bed3-c944770feabb",
    "http://103.191.208.239:8065/chintan/messages/@avadhut"
)
Open-ChromeWithProfile -Profile "Profile 3" -Urls $urls
Write-Host "Chrome launched with Profile 3"

# Launch Obsidian and MonoSnap
if (Test-Path $obsidianPath) {
    Start-Process $obsidianPath
    Write-Host "Obsidian launched successfully"
} else {
    Write-Host "Obsidian not found at $obsidianPath"
}

if (Test-Path $monosnapPath) {
    Start-Process $monosnapPath
    Write-Host "MonoSnap launched successfully"
} else {
    Write-Host "MonoSnap not found at $monosnapPath"
}

# Main navigation loop
$current_dir = $courseDir

while ($true) {
    Write-Host "`nCurrent directory: $current_dir"
    Write-Host "Contents:"
    
    # Get all items in current directory
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
            if ($current_dir -ne $courseDir) {
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
                    
                    # Open corresponding course website
                    switch ($selected_item.Name) {
                        "Part1  [Hacksnation.com]" {
                            Open-ChromeWithProfile -Profile "Profile 3" -Urls @("https://codewithmosh.com/p/the-ultimate-html-css-part1")
                        }
                        "Part2  [Hacksnation.com]" {
                            Open-ChromeWithProfile -Profile "Profile 3" -Urls @("https://codewithmosh.com/p/the-ultimate-html-css-part2")
                        }
                        "Part3  [Hacksnation.com]" {
                            Open-ChromeWithProfile -Profile "Profile 3" -Urls @("https://codewithmosh.com/p/the-ultimate-html-css-part3")
                        }
                    }
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