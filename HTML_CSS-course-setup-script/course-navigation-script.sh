#!/bin/bash

# Chrome executable path
CHROME_PATH="/opt/google/chrome/google-chrome"

# Profile path (using Profile 3 as per the information provided)
PROFILE_PATH="/home/avadhut/.config/google-chrome/Profile 3"

# Open Chrome with the specified profile and URLs
"$CHROME_PATH" --profile-directory="Profile 28" \
    "https://chatgpt.com/c/66ea74a3-8850-8006-bed3-c944770feabb" \
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

# Function to play video
play_video() {
    local video_file="$1"
    if [ -f "$video_file" ]; then
        echo "Playing $video_file"
        celluloid "$video_file" &
    else
        echo "File not found: $video_file"
    fi
}

# Main navigation loop
main_dir="/home/avadhut/Downloads/Course"
current_dir="$main_dir"

while true; do
    echo "Current directory: $current_dir"
    echo "Contents:"
    list_directory "$current_dir"
    echo "Enter a number to select an item, 'b' to go back, or 'q' to quit:"
    read choice

    case $choice in
        q)
            echo "Exiting script."
            exit 0
            ;;
        b)
            if [ "$current_dir" != "$main_dir" ]; then
                current_dir=$(dirname "$current_dir")
            else
                echo "Already at the main directory."
            fi
            ;;
        [0-9]*)
            selected_item=$(ls -1 "$current_dir" | sed -n "${choice}p")
            if [ -z "$selected_item" ]; then
                echo "Invalid selection."
            elif [ -d "$current_dir/$selected_item" ]; then
                current_dir="$current_dir/$selected_item"
                
                # Open corresponding course website
                case "$selected_item" in
                    "Part1  [Hacksnation.com]")
                        "$CHROME_PATH" --profile-directory="Profile 3" "https://codewithmosh.com/p/the-ultimate-html-css-part1" &
                        ;;
                    "Part2  [Hacksnation.com]")
                        "$CHROME_PATH" --profile-directory="Profile 3" "https://codewithmosh.com/p/the-ultimate-html-css-part2" &
                        ;;
                    "Part3  [Hacksnation.com]")
                        "$CHROME_PATH" --profile-directory="Profile 3" "https://codewithmosh.com/p/the-ultimate-html-css-part3" &
                        ;;
                esac
            elif [[ "$selected_item" == *.mp4 ]]; then
                while true; do
                    play_video "$current_dir/$selected_item"
                    echo "Video playback initiated. What would you like to do next?"
                    echo "1. Play another video from this folder"
                    echo "2. Go back to folder navigation"
                    read -p "Enter your choice (1 or 2): " next_action
                    case $next_action in
                        1) 
                            echo "Select another video:"
                            list_directory "$current_dir"
                            read -p "Enter the number of the video you want to play: " video_choice
                            selected_item=$(ls -1 "$current_dir"/*.mp4 | sed -n "${video_choice}p")
                            if [ -z "$selected_item" ]; then
                                echo "Invalid selection. Returning to folder navigation."
                                break
                            fi
                            ;;
                        2) break ;;
                        *) echo "Invalid choice. Returning to folder navigation."; break ;;
                    esac
                done
            else
                echo "Selected item is not a directory or MP4 file."
            fi
            ;;
        *)
            echo "Invalid input. Please try again."
            ;;
    esac
done
