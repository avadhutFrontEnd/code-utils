# Store original location
$originalLocation = Get-Location

# Define the course directory
$courseDir = "C:\Users\Avadhut\Desktop\Courses\code with mosh\2) React\01 - Getting Started (00h28m)\01 - Getting Started (00h28m)"

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

# Directly set the profile to "Profile 4"
$selectedProfile = "Profile 4"

# URLs to open
$urls = @(
    "https://chatgpt.com/c/672472bb-1d98-8006-ae29-7e0e914a4b14",
    "https://codewithmosh.com/p/mastering-react",
    "http://103.191.208.239:8065/chintan/messages/@avadhut",
    "https://github.com/avadhutFrontEnd/react-projects"
)

# Step 1: Open Chrome with Profile 4 and specified URLs
Open-ChromeWithProfile -Profile $selectedProfile -Urls $urls
Write-Host "Chrome launched with profile: $selectedProfile"

# Step 2: Open both directories in File Explorer
# Fixed: Use explorer.exe with quoted paths for spaces
Start-Process "explorer.exe" -ArgumentList "`"$courseDir`""
$projectPath = "C:\Users\Avadhut\Desktop\git\1_React\react-projects"
Start-Process "explorer.exe" -ArgumentList "`"$projectPath`""
Write-Host "File Explorer opened for both course and project directories"

# Step 3: Open the specified directory in VS Code
Start-Process code -ArgumentList $projectPath
Write-Host "VS Code launched with directory: $projectPath"

# Step 4: Open Obsidian and MonoSnap
$obsidianPath = "C:\Users\Avadhut\AppData\Local\Obsidian\Obsidian.exe"
$monosnapPath = "C:\Users\Avadhut\AppData\Local\Monosnap\Monosnap.exe"

if (Test-Path $obsidianPath) {
    Start-Process $obsidianPath
    Write-Host "Obsidian launched successfully"
} else {
    Write-Host "Obsidian not found at $obsidianPath. Please update the path."
}

if (Test-Path $monosnapPath) {
    Start-Process $monosnapPath
    Write-Host "MonoSnap launched successfully"
} else {
    Write-Host "MonoSnap not found at $monosnapPath. Please update the path."
}


# Get the list of .mp4 files in the directory
$videos = Get-ChildItem -Path $courseDir -Filter *.mp4 | Sort-Object Name

# List the files with numbering
Write-Host "Available video files:`n"
for ($i = 0; $i -lt $videos.Length; $i++) {
    Write-Host "$($i + 1). $($videos[$i].Name)"
}

# Prompt user to enter the lesson number
$lessonIndex = [int](Read-Host "Enter the lesson number you want to open (e.g., 1 for the first video)")

# Validate input and play the video if valid (fixed validation logic)
if ($lessonIndex -ge 1 -and $lessonIndex -le $videos.Length) {
    $selectedVideo = $videos[$lessonIndex - 1].FullName
    Write-Host "Playing video: $selectedVideo"
    # Path to PotPlayer, update if necessary
    $potPlayerPath = "C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"
    if (Test-Path $potPlayerPath) {
        # Fixed: Wrap path in quotes and use Start-Process with -FilePath and -ArgumentList
        Start-Process -FilePath $potPlayerPath -ArgumentList "`"$selectedVideo`""
    } else {
        Write-Host "PotPlayer not found at $potPlayerPath. Please update the path."
    }
} else {
    Write-Host "Invalid selection. Please enter a number between 1 and $($videos.Length)."
}

# Return to original location
Set-Location $originalLocation
Write-Host "Script completed. PowerShell location restored to: $originalLocation"