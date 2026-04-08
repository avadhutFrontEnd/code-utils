#!/usr/bin/env bash
# DSA (Code with Mosh): prompt Topic 1/2/3, open video + subtitles in Explorer (WSL) or file manager (Linux),
# then Cursor (notes), Obsidian, Monosnap (Windows apps when under WSL).
#
# Usage:
#   chmod +x open-dsa-code-with-mosh-workspace.sh
#   ./open-dsa-code-with-mosh-workspace.sh
#
# Optional: export WIN_USER=YourWindowsUser   if your Windows profile name differs.

set -uo pipefail

WIN_USER="${WIN_USER:-Avadhut}"
BASE="/mnt/c/Users/${WIN_USER}"

COURSE_BASE="${BASE}/Desktop/Courses/code with mosh/5) Data Structure"

CURSOR_NOTES="${BASE}/Desktop/OfficeDataGDriveSync/Obsidean/Avadhut Notes FolderSync/Avadhut Notes Google Drive/0. Data Structure and Algorithum/Code with Mosh"
OBSIDIAN_WIN="${BASE}/AppData/Local/Obsidian/Obsidian.exe"
MONOSNAP_WIN="${BASE}/AppData/Local/Monosnap/Monosnap.exe"
CURSOR_WIN="${BASE}/AppData/Local/Programs/cursor/Cursor.exe"
EXPLORER_WIN="/mnt/c/Windows/explorer.exe"

# Native Linux (optional): set these if your course/notes live under Linux paths
: "${DSA_COURSE_BASE_LINUX:=}"
: "${DSA_NOTES_LINUX:=}"

is_wsl() {
  [[ -f /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version
}

warn_missing_dir() {
  local d="$1"
  if [[ ! -d "$d" ]]; then
    echo "Warning: path not found: $d" >&2
  fi
}

open_folder_windows() {
  local win_path="$1"
  if [[ ! -d "$win_path" ]]; then
    echo "Warning: not a directory: $win_path" >&2
    return 1
  fi
  local w
  w="$(wslpath -w "$win_path" 2>/dev/null)" || return 1
  "$EXPLORER_WIN" "$w" &
  echo "Explorer: $w"
}

open_folder_linux() {
  local d="$1"
  warn_missing_dir "$d"
  if command -v xdg-open &>/dev/null; then
    xdg-open "$d" 2>/dev/null &
    echo "Opened (xdg-open): $d"
  else
    echo "Install xdg-utils (xdg-open) or set DSA_COURSE_BASE_LINUX / paths." >&2
  fi
}

launch_cursor_notes() {
  local notes_path="$1"
  warn_missing_dir "$notes_path"

  if command -v cursor &>/dev/null; then
    cursor "$notes_path" || true
    echo "Cursor: DSA notes (PATH)"
  elif [[ -f "$CURSOR_WIN" ]]; then
    local wnotes
    wnotes="$(wslpath -w "$notes_path")"
    "$CURSOR_WIN" "$wnotes" &
    echo "Cursor: DSA notes ($CURSOR_WIN)"
  else
    echo "Cursor not found. Install Cursor or set CURSOR_WIN." >&2
  fi
}

launch_obsidian() {
  if [[ -f "$OBSIDIAN_WIN" ]]; then
    "$OBSIDIAN_WIN" &
    echo "Obsidian launched."
  elif command -v obsidian &>/dev/null; then
    obsidian &
    echo "Obsidian (Linux) launched."
  elif command -v flatpak &>/dev/null && flatpak info md.obsidian.Obsidian &>/dev/null; then
    flatpak run md.obsidian.Obsidian &
    echo "Obsidian (Flatpak) launched."
  else
    echo "Obsidian not found at $OBSIDIAN_WIN (WSL) or on Linux PATH." >&2
  fi
}

launch_monosnap() {
  if [[ -f "$MONOSNAP_WIN" ]]; then
    "$MONOSNAP_WIN" &
    echo "Monosnap launched."
  else
    echo "Monosnap not found at $MONOSNAP_WIN — install on Windows or ignore under native Linux." >&2
  fi
}

DSA_TOPIC=""

prompt_topic() {
  if [[ -n "${DSA_TOPIC:-}" ]] && [[ "$DSA_TOPIC" =~ ^[123]$ ]]; then
    echo "Topic (non-interactive): $DSA_TOPIC"
    return 0
  fi
  DSA_TOPIC=""
  while true; do
    echo ""
    echo "DSA — Code with Mosh workspace"
    echo "Which topic? 1 = Part 1, 2 = Part 2, 3 = Part 3"
    read -r -p "Enter 1, 2, or 3: " DSA_TOPIC
    case "$DSA_TOPIC" in
      1|2|3) return 0 ;;
      *) echo "Invalid choice. Use 1, 2, or 3." ;;
    esac
  done
}

run_wsl() {
  if [[ ! -d "/mnt/c" ]]; then
    echo "/mnt/c not available — start WSL from Windows or enable interop." >&2
    exit 1
  fi

  prompt_topic
  local topic="$DSA_TOPIC"

  local videos subtitles
  case "$topic" in
    1)
      videos="${COURSE_BASE}/Data Structures and Algorithms Part 1"
      subtitles="${COURSE_BASE}/Data Structures and Algorithms Part 1/Part 1-20260326T171912Z-3-001/Part 1"
      ;;
    2)
      videos="${COURSE_BASE}/Data Structures and Algorithms Part 2"
      subtitles="${COURSE_BASE}/Data Structures and Algorithms Part 2/Part 2-20260326T171913Z-3-001/Part 2/subtitles-folders-part2"
      ;;
    3)
      videos="${COURSE_BASE}/Data Structures and Algorithms Part 3"
      subtitles="${COURSE_BASE}/Data Structures and Algorithms Part 3/subtitles-folders-part3"
      ;;
  esac

  echo ""
  echo "Opening video folder and subtitles folder..."
  open_folder_windows "$videos" || true
  open_folder_windows "$subtitles" || true

  launch_cursor_notes "$CURSOR_NOTES"
  launch_obsidian
  launch_monosnap
}

run_native_linux() {
  echo "Not under WSL — using native Linux paths (set DSA_COURSE_BASE_LINUX / DSA_NOTES_LINUX if needed)." >&2

  prompt_topic
  local topic="$DSA_TOPIC"

  local base="${DSA_COURSE_BASE_LINUX:-$HOME/Desktop/Courses/code with mosh/5) Data Structure}"
  local videos subtitles
  case "$topic" in
    1)
      videos="${base}/Data Structures and Algorithms Part 1"
      subtitles="${base}/Data Structures and Algorithms Part 1/Part 1-20260326T171912Z-3-001/Part 1"
      ;;
    2)
      videos="${base}/Data Structures and Algorithms Part 2"
      subtitles="${base}/Data Structures and Algorithms Part 2/Part 2-20260326T171913Z-3-001/Part 2/subtitles-folders-part2"
      ;;
    3)
      videos="${base}/Data Structures and Algorithms Part 3"
      subtitles="${base}/Data Structures and Algorithms Part 3/subtitles-folders-part3"
      ;;
  esac

  echo ""
  echo "Opening video folder and subtitles folder..."
  open_folder_linux "$videos"
  open_folder_linux "$subtitles"

  local notes="${DSA_NOTES_LINUX:-$HOME/OfficeDataGDriveSync/Obsidean/Avadhut Notes FolderSync/Avadhut Notes Google Drive/0. Data Structure and Algorithum/Code with Mosh}"
  warn_missing_dir "$notes"

  if command -v cursor &>/dev/null; then
    cursor "$notes" || true
    echo "Cursor: DSA notes"
  else
    echo "cursor CLI not on PATH — open the notes folder manually: $notes" >&2
    xdg-open "$notes" 2>/dev/null || true
  fi

  launch_obsidian
  if command -v monosnap &>/dev/null; then
    monosnap &
    echo "Monosnap (Linux) launched."
  else
    echo "Monosnap is Windows-only in default setup; skipped on Linux." >&2
  fi
}

# Optional: ./open-dsa-code-with-mosh-workspace.sh 2
if [[ "${1:-}" =~ ^[123]$ ]]; then
  DSA_TOPIC="$1"
fi

if is_wsl; then
  run_wsl
else
  run_native_linux
fi

echo ""
echo "Done."
