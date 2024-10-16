#!/bin/bash

# Chrome executable path
CHROME_PATH="/opt/google/chrome/google-chrome"

# Profile path (using Profile 3 as per the information provided)
PROFILE_PATH="/home/avadhut/.config/google-chrome/Profile 3"

# Open Chrome with the specified profile and URLs
"$CHROME_PATH" --profile-directory="Profile 3" \
    "https://chatgpt.com/c/66ea74a3-8850-8006-bed3-c944770feabb" \
    "https://codewithmosh.com/p/the-ultimate-typescript" \
    "http://103.191.208.239:8065/chintan/messages/@avadhut" &

# Open Obsidian
obsidian_path="/home/avadhut/Desktop/Obsidian-1.6.7.AppImage"

if [ -f "$obsidian_path" ]; then
    "$obsidian_path" &
else
    echo "Obsidian AppImage not found at the specified path."
fi

echo "Chrome has been launched with Profile 3 and specified URLs."
echo "Obsidian should also be opening if the AppImage was found."

# Function to list directory contents
list_directory() {
    local dir="$1"
    local i=1
    for item in "$dir"/*; do
        if [ -e "$item" ]; then
            echo "$i. $(basename "$item")"
            i=$((i+1))
        fi
    done
}

# List contents of the specified directory
echo "Contents of /home/avadhut/Downloads/CodeWithMoshTheUltimateTypeScript:"
list_directory "/home/avadhut/Downloads/CodeWithMoshTheUltimateTypeScript"

# Ask user for input
read -p "Enter a number to list contents of a subdirectory (or 'q' to quit): " choice

if [ "$choice" != "q" ]; then
    subdirectory=$(ls -1 /home/avadhut/Downloads/CodeWithMoshTheUltimateTypeScript | sed -n "${choice}p")
    if [ -n "$subdirectory" ]; then
        full_path="/home/avadhut/Downloads/CodeWithMoshTheUltimateTypeScript/$subdirectory"
        echo "Contents of $full_path:"
        list_directory "$full_path"
        
        read -p "Enter a number to play a video (or 'q' to quit): " video_choice
        if [ "$video_choice" != "q" ]; then
            video_file=$(ls -1 "$full_path"/*.mp4 2>/dev/null | sed -n "${video_choice}p")
            if [ -n "$video_file" ]; then
                echo "Playing $video_file"
                xdg-open "$video_file" &
            else
                echo "No video file found with that number."
            fi
        fi
    else
        echo "Invalid selection."
    fi
fi

echo "Script execution completed."
