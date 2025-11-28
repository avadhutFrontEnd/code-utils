# JavaScript Patterns Link Opener Script
# Store original location
$originalLocation = Get-Location

# Define Chrome executable path
$chromeExe = "C:\Program Files\Google\Chrome\Application\chrome.exe"

# Chrome Profile Mappings
$profiles = @{
    "avadhutproject123@gmail.com" = "Profile 4"
    "avadhut.reactdev@gmail.com" = "Profile 8"
}

# Function to open Chrome with a specific profile and URLs
function Open-ChromeWithProfile {
    param (
        [string]$Profile,
        [string[]]$Urls
    )
    $args = @("--profile-directory=`"$Profile`"") + $Urls
    Start-Process $chromeExe -ArgumentList $args
    Write-Host "Opening Chrome with profile: $Profile"
}

# Function to get profile for email
function Get-ProfileForEmail {
    param([string]$email)
    return $profiles[$email]
}

# JavaScript Patterns Data Structure
$jsPatterns = @{
    "1" = @{
        "name" = "Variable Declaration & Scope"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/54ec69b6-16a9-45b8-98ad-17c5c28d715e"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/73959c50-0b7e-4e65-9d03-2bdb8e41e2c9"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/b4847d53-4e71-493a-947c-be230e90b78d"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/686f8cea-910c-8007-a2d5-1db6a7fae4e1"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "2" = @{
        "name" = "Function Patterns"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/0c90dfa8-1fa3-497f-aa35-6608ce85a644"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/3c9a5538-80f9-4a88-9855-dbf200e8b146"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/da33c054-629c-41a2-bd67-105c5b13b1c1"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/6870e4a2-a4f4-8007-84b7-ae563a0c83a5"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "3" = @{
        "name" = "Object Manipulation"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/3e56fb8f-2e84-4f9a-8550-06024664ac9b"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/13e1550c-3c4e-4ac5-963c-f07a355f526d"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/567bca5a-d940-4565-9f50-d62512d72640"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/68720e2a-7070-8007-a35b-24cd0d9519e4"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "4" = @{
        "name" = "Array Transformation"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/4a6ac2e8-519f-4000-b2cb-88a1187d8e20"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/a997eae1-3556-476b-b2de-b3449b314b47"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/b8ba7d21-c7fb-4b9f-870a-53d8413919b5"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/68722253-cc40-8007-b44b-7ae62a72140c"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "5" = @{
        "name" = "Template Literals & String Manipulation"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/e166dde6-c733-46dc-af90-11ce81937e96"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/90e59694-35e1-4d3e-98ad-45965fdb9db0"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/9dea97ab-e02f-4819-b394-4e6cacaf66cf"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/6872558c-a27c-8007-a542-8abbd346289b"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "6" = @{
        "name" = "Event Listeners"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/c6272237-2c3e-4882-96fd-2ec91962b6c2"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/a2bcab0e-d5c6-4360-9b60-1874d33a9742"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/b44a9155-51c6-407f-abd1-67219750d4f4"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/68727ba8-2400-8007-bf94-52662e3ccae2"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "7" = @{
        "name" = "Event Delegation"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/5e305a55-ac4b-4dfc-8941-b80a6f767eee"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/fd1a1799-95b8-426b-b959-d0918ebdf564"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/f7d1321b-0e4a-46d4-bdc6-4e71ccbf5767"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/68728c65-deb8-8007-b155-2f61ffa27c01"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "10" = @{
        "name" = "Element Selection & Caching"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/1c8c08d8-5480-4125-b998-3b466f3ac0bf"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/fb27ba8a-779e-465a-a755-9120d9e175f8"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/2b033c86-4842-4495-a9af-134bde45e9de"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/68729335-8f00-8007-a11e-84e2b6ebef7d"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "11" = @{
        "name" = "Dynamic Element Creation"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/0311ee79-4502-4b91-8286-f496a8277c58"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/e0e9ae0c-ae2b-4f09-9122-4bdf53bc6b07"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/362873b5-ead9-43c3-a0d3-8ca1e5233168"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/68735073-eeac-8007-a301-573082b457d1"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "12" = @{
        "name" = "Class & Style Manipulation"
        "links" = @(
            @{ "url" = "https://claude.ai/chat/bce6c3c4-a1ae-4e7a-9a6e-f86f12ac9e8f"; "email" = "avadhutproject123@gmail.com" },
            @{ "url" = "https://grok.com/chat/654abf45-a550-4205-9b3c-f561acf30590"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://grok.com/chat/16582ba1-fe97-4bc2-afc4-130cec2b9ef0"; "email" = "avadhut.reactdev@gmail.com" },
            @{ "url" = "https://chatgpt.com/c/68735e9f-ed54-8007-b505-ecb739d296d1"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
    "0" = @{
        "name" = "StackBlitz - All Patterns"
        "links" = @(
            @{ "url" = "https://stackblitz.com/edit/stackblitz-starters-idmyv7bn?file=pattern-02-Function-Pattern%2Findex.html,pattern-02-Function-Pattern%2Fpractice.js"; "email" = "avadhut.reactdev@gmail.com" }
        )
    }
}

# Function to display menu
function Show-Menu {
    Write-Host "`n=== JavaScript Patterns Link Opener ===`n"
    Write-Host "0. StackBlitz - All Patterns Question"
    Write-Host "1. Variable Declaration & Scope"
    Write-Host "2. Function Patterns" 
    Write-Host "3. Object Manipulation"
    Write-Host "4. Array Transformation"
    Write-Host "5. Template Literals & String Manipulation"
    Write-Host "6. Event Listeners"
    Write-Host "7. Event Delegation"
    Write-Host "10. Element Selection & Caching"
    Write-Host "11. Dynamic Element Creation"
    Write-Host "12. Class & Style Manipulation"
    Write-Host "`nq. Quit"
    Write-Host "`n" -NoNewline
}

# Function to open pattern links
function Open-PatternLinks {
    param([string]$patternNumber)
    
    if (-not $jsPatterns.ContainsKey($patternNumber)) {
        Write-Host "Invalid pattern number!"
        return
    }
    
    $pattern = $jsPatterns[$patternNumber]
    Write-Host "`nOpening links for: $($pattern.name)"
    
    # Group links by email/profile
    $linksByProfile = @{}
    foreach ($link in $pattern.links) {
        $profile = Get-ProfileForEmail $link.email
        if (-not $linksByProfile.ContainsKey($profile)) {
            $linksByProfile[$profile] = @()
        }
        $linksByProfile[$profile] += $link.url
    }
    
    # Open each profile group
    foreach ($profile in $linksByProfile.Keys) {
        $urls = $linksByProfile[$profile]
        Write-Host "Opening $($urls.Count) links with profile: $profile"
        Open-ChromeWithProfile -Profile $profile -Urls $urls
        Start-Sleep -Milliseconds 500  # Small delay between profile openings
    }
}

# Main execution
Write-Host "JavaScript Patterns Link Opener Script"
Write-Host "======================================"

# Check if Chrome profile for avadhut.reactdev@gmail.com is correctly set
if ($profiles["avadhut.reactdev@gmail.com"] -eq "Default") {
    Write-Host "`nWARNING: Chrome profile for avadhut.reactdev@gmail.com is set to 'Default'"
    Write-Host "This might not be correct. Would you like to identify the correct profile? (y/n)"
    $response = Read-Host
    if ($response -eq "y" -or $response -eq "Y") {
        $correctProfile = Find-ChromeProfile
        $profiles["avadhut.reactdev@gmail.com"] = $correctProfile
        Write-Host "Profile updated to: $correctProfile"
    }
}

# Main menu loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    
    switch ($choice.ToLower()) {
        'q' {
            Write-Host "Exiting script."
            Set-Location $originalLocation
            exit
        }
        { $_ -in @('0', '1', '2', '3', '4', '5', '6', '7', '10', '11', '12') } {
            Open-PatternLinks $choice
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
    
    Write-Host "`nPress Enter to continue..."
    Read-Host
}