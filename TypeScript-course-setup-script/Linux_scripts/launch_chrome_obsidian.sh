#!/bin/bash

# Chrome executable path
CHROME_PATH="/opt/google/chrome/google-chrome"

# Profile path (using Profile 3 as per the information provided)
PROFILE_PATH="/home/avadhut/.config/google-chrome/Profile 3"

# Open Chrome with the specified profile and URLs
"$CHROME_PATH" --profile-directory="Profile 3" \
    "https://chatgpt.com/c/66ea74a3-8850-8006-bed3-c944770feabb" \
    "https://codewithmosh.com/p/the-ultimate-typescript" &

# Open Obsidian
obsidian_path="/home/avadhut/Desktop/Obsidian-1.6.7.AppImage"

if [ -f "$obsidian_path" ]; then
    "$obsidian_path" &
else
    echo "Obsidian AppImage not found at the specified path."
fi

echo "Chrome has been launched with Profile 3 and specified URLs."
echo "Obsidian should also be opening if the AppImage was found."
