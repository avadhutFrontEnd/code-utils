# Store original location
$originalLocation = Get-Location

# Define the course directory
$courseDir = "C:\Users\Avadhut\Desktop\Courses\code with mosh\8) React_with_TypeSC\2__React_18_Intermediate_Topics\React_Intermediate_Topics\React_Intermediate_Topics"

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
    "https://chatgpt.com/c/66dc6d68-2ac8-8006-8e02-c89b4e2706b1",
    "https://codewithmosh.com/p/ultimate-react-part2",
    "https://chat.chintandev.in/chintan/messages/@avadhut"
)

# Step 1: Open Chrome with Profile 4 and specified URLs
Open-ChromeWithProfile -Profile $selectedProfile -Urls $urls
Write-Host "Chrome launched with profile: $selectedProfile"

# Step 2: Open both directories in File Explorer
# Fixed: Use explorer.exe with quoted paths for spaces
Start-Process "explorer.exe" -ArgumentList "`"$courseDir`""
$projectPath = "C:\Users\Avadhut\Desktop\git\1_React\react-ts-part-2\Playground Starter"
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

# Return to original location
Set-Location $originalLocation
Write-Host "Script completed. PowerShell location restored to: $originalLocation"