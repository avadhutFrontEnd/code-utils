#!/bin/bash

# Activate the Python environment
source ~/Desktop/whisper_env/bin/activate

# Ask user for input directory
read -p "Enter the directory containing the videos: " video_dir

# Remove trailing slash if present
video_dir=${video_dir%/}

# Check if video directory exists
if [ ! -d "$video_dir" ]; then
  echo "Video directory does not exist: $video_dir"
  exit 1
fi

# Ask user for output directory
read -p "Enter the output directory for transcriptions: " output_dir

# Remove trailing slash if present
output_dir=${output_dir%/}

# Check if output directory exists, create if not
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
fi

# Loop through all mp4 files in the video directory
for video in "$video_dir"/*.mp4; do
  # Check if there are any mp4 files
  if [ ! -e "$video" ]; then
    echo "No mp4 files found in $video_dir"
    exit 1
  fi

  # Extract the base name of the video (without path)
  video_name=$(basename "$video")
  
  # Run the Whisper transcription command
  echo "Processing video: $video_name"
  python -m whisper "$video" --task transcribe --output_dir "$output_dir"
  
  # Check if the command was successful
  if [ $? -ne 0 ]; then
    echo "Error processing video: $video_name"
  else
    echo "Successfully processed: $video_name"
  fi
done

echo "All videos have been processed."
