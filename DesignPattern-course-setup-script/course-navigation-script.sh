#!/bin/bash

# Design Pattern course paths
COURSE_BASE="/path/to/CodeWithMosh - Design Patterns"
SUBTITLES_BASE="$COURSE_BASE/Subtitles"
CURSOR_NOTES_PATH="/path/to/Avadhut Notes Google Drive/1. Web Development/CWM - The Ultimate Design Pattern Series"

# Chrome executable path
CHROME_PATH="/opt/google/chrome/google-chrome"
PROFILE_PATH="/home/avadhut/.config/google-chrome/Profile 4"

# Part-specific folder names
declare -A PART_NAMES
PART_NAMES[1]="The Ultimate Design Patterns Part 1"
PART_NAMES[2]="The Ultimate Design Patterns Part 2"
PART_NAMES[3]="The Ultimate Design Patterns Part 3"

# Ask user which part to study
echo ""
echo "========================================"
echo "  Design Patterns Course Setup Script"
echo "========================================"
echo ""
echo "Which part would you like to study?"
echo "  1. Part 1 - Behavioral Patterns (4h, 13 sections)"
echo "  2. Part 2 - Structural Patterns (2h, 9 sections)"
echo "  3. Part 3 - Creational Patterns (1h, 7 sections)"
echo ""

while true; do
    read -p "Enter part number (1, 2, or 3): " PART_CHOICE
    case $PART_CHOICE in
        1|2|3) break ;;
        *) echo "Invalid choice. Please enter 1, 2, or 3." ;;
    esac
done

SELECTED_PART="${PART_NAMES[$PART_CHOICE]}"
COURSE_ROOT="$COURSE_BASE/$SELECTED_PART"
SUBTITLES_DIR="$SUBTITLES_BASE/$SELECTED_PART"

echo ""
echo "Selected: $SELECTED_PART"
echo ""

# Open Chrome with the specified profile and Claude AI
"$CHROME_PATH" --profile-directory="Profile 4" \
    "https://claude.ai/new" &

# Open Obsidian
obsidian_path="/home/avadhut/Desktop/Obsidian-1.6.7.AppImage"
if [ -f "$obsidian_path" ]; then
    "$obsidian_path" &
else
    echo "Obsidian AppImage not found at the specified path."
fi

# Open video folder and subtitles in file manager
if [ -d "$COURSE_ROOT" ]; then
    xdg-open "$COURSE_ROOT" 2>/dev/null || true
fi
if [ -d "$SUBTITLES_DIR" ]; then
    xdg-open "$SUBTITLES_DIR" 2>/dev/null || true
fi

echo "Chrome launched with Claude AI new chat."
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
current_dir="$COURSE_ROOT"

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
            if [ "$current_dir" != "$COURSE_ROOT" ]; then
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
                            selected_item=$(ls -1 "$current_dir"/*.mp4 2>/dev/null | sed -n "${video_choice}p" | xargs basename 2>/dev/null)
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
