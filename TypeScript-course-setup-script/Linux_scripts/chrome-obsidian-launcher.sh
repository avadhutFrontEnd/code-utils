#!/bin/bash

# Open Chrome with default profile and specified URLs
google-chrome --profile-directory=Default \
    "https://chatgpt.com/c/66ea74a3-8850-8006-bed3-c944770feabb" \
    "https://codewithmosh.com/p/the-ultimate-typescript" &

# Open Obsidian
obsidian_path="/home/avadhut/Desktop/Obsidian-1.6.7.AppImage"

if [ -f "$obsidian_path" ]; then
    "$obsidian_path" &
else
    echo "Obsidian AppImage not found at the specified path."
fi

echo "Chrome has been launched with the default profile and specified URLs."
echo "Obsidian should also be opening if the AppImage was found."
