# Docker Course Setup Automation Script


# Function to open Chrome with a specific profile and URLs
function Open-ChromeWithProfile {
    param (
        [string]$Profile,
        [string[]]$Urls
    )
    $chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    $args = @("--profile-directory=`"$Profile`"") + $Urls
    Start-Process $chromeExe -ArgumentList $args
}

# Path to Chrome user data directory
$userDataDir = "C:\Users\$env:USERNAME\AppData\Local\Google\Chrome\User Data"

# Get all profile directories (except 'System Profile')
$profiles = Get-ChildItem -Directory -Path $userDataDir | Where-Object { $_.Name -ne "System Profile" }

# Display profiles and ask user to choose one
Write-Host "Select the profile you want to open:"
for ($i = 0; $i -lt $profiles.Count; $i++) {
    Write-Host "$($i + 1): $($profiles[$i].Name)"
}

$profileNumber = Read-Host "Enter the number of the profile"
$profileIndex = [int]$profileNumber - 1

if ($profileIndex -lt 0 -or $profileIndex -ge $profiles.Count) {
    Write-Host "Invalid selection. Exiting script."
    exit
}

$selectedProfile = $profiles[$profileIndex].Name

# URLs to open (adjust or add more URLs as needed)
$urls = @(
    "https://codewithmosh.com/p/the-ultimate-docker-course",
    "http://103.191.208.239:8065/chintan/messages/@avadhut",
    "https://chatgpt.com/c/66dc4e64-44f8-8006-a95a-1c15eb14a7c8"
)

# Step 1 & 2: Open Chrome with the selected profile and specified URLs
Open-ChromeWithProfile -Profile $selectedProfile -Urls $urls

# Print success message
Write-Host "Chrome launched with profile: $selectedProfile"


# Step 3: Open Obsidian and MonoSnap (adjust paths as necessary)
$obsidianPath = "C:\Users\Avadhut\AppData\Local\Obsidian\Obsidian.exe"
$monosnapPath = "C:\Users\Avadhut\AppData\Local\Monosnap\Monosnap.exe"

if (Test-Path $obsidianPath) {
    Start-Process $obsidianPath
} else {
    Write-Host "Obsidian not found at $obsidianPath. Please update the path."
}

if (Test-Path $monosnapPath) {
    Start-Process $monosnapPath
} else {
    Write-Host "MonoSnap not found at $monosnapPath. Please update the path."
}

# Step 4: Navigate to course directory and open it in File Explorer
$courseDir = "C:\Users\Avadhut\Desktop\Courses\code with mosh\9) The Ultimate Docker Course\Codewithmosh.com - The Ultimate Docker Course"
Set-Location -Path $courseDir
Start-Process explorer.exe $courseDir

# Function to list video files
function List-VideoFiles {
    Get-ChildItem -Filter "lesson*.mp4" | Format-Table Name, Length, LastWriteTime
}

# List available video files
Write-Host "Available video files:"
List-VideoFiles

# Ask user which file to open
$fileNumber = Read-Host "Enter the lesson number you want to open (e.g., 21 for lesson21.mp4)"

# Construct file name
$fileName = "lesson$fileNumber.mp4"

# Check if file exists
if (Test-Path $fileName) {
    # Open file with PotPlayer (adjust path as necessary)
    $potPlayerPath = "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"
    if (Test-Path $potPlayerPath) {
        Start-Process $potPlayerPath -ArgumentList "`"$courseDir\$fileName`"" 
    } else {
        Write-Host "PotPlayer not found at $potPlayerPath. Please update the path."
    }
} else {
    Write-Host "File not found: $fileName"
}
