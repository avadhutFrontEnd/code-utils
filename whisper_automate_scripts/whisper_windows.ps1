# Change to the directory where the virtual environment is located
cd C:\Users\Avadhut\Desktop\whisper_setup

# Activate the Python environment
& .\whisper_env\Scripts\Activate.ps1

# Prompt the user for input and output directories
$video_dir = Read-Host -Prompt "Enter the directory containing the videos"
$output_dir = Read-Host -Prompt "Enter the output directory for transcriptions"

# Remove trailing slashes if present
$video_dir = $video_dir.TrimEnd('\')
$output_dir = $output_dir.TrimEnd('\')

# Check if video directory exists
if (!(Test-Path -Path $video_dir -PathType Container)) {
    Write-Host "Video directory does not exist: $video_dir"
    exit 1
}

# Check if output directory exists, create if not
if (!(Test-Path -Path $output_dir -PathType Container)) {
    New-Item -ItemType Directory -Path $output_dir | Out-Null
}

# Get all mp4 files in the input directory
$mp4Files = Get-ChildItem -Path "$video_dir\*.mp4"

if ($mp4Files.Count -eq 0) {
    Write-Host "No mp4 files found in $video_dir"
    exit 1
}

# Loop through each mp4 file and run Whisper
foreach ($video in $mp4Files) {
    $video_name = $video.Name
    $video_path = $video.FullName
    
    Write-Host "Processing video: $video_name"
    
    # Run Whisper with specified model and language
    whisper "$video_path" --model base --language en --output_dir "$output_dir"
    
    # Check if the command was successful
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error processing video: $video_name"
    } else {
        Write-Host "Successfully processed: $video_name"
    }
}

Write-Host "All videos have been processed."
