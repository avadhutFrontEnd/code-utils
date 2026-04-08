#!/usr/bin/env bash
# Opens Javascript-info notes in Cursor (WSL -> Windows Cursor) and Windows Obsidian.
# Mirrors open-javascript-info-workspace.ps1.
#
# Usage (WSL):
#   chmod +x open-javascript-info-workspace.sh
#   ./open-javascript-info-workspace.sh
#
# Optional: export WIN_USER=YourWindowsUser   if your Windows profile name ≠ Linux default below

set -uo pipefail

WIN_USER="${WIN_USER:-Avadhut}"
BASE="/mnt/c/Users/${WIN_USER}"

JS_INFO="${BASE}/Desktop/OfficeDataGDriveSync/Obsidean/Avadhut Notes FolderSync/Avadhut Notes Google Drive/1. Web Development/3. JavaScript/Javascript-info"
OBSIDIAN_WIN="${BASE}/AppData/Local/Obsidian/Obsidian.exe"
CURSOR_WIN="${BASE}/AppData/Local/Programs/cursor/Cursor.exe"

is_wsl() {
  [[ -f /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version
}

warn_missing_dir() {
  local d="$1"
  if [[ ! -d "$d" ]]; then
    echo "Warning: path not found: $d" >&2
  fi
}

launch_wsl() {
  warn_missing_dir "$JS_INFO"

  if command -v cursor &>/dev/null; then
    cursor "$JS_INFO" || true
    echo "Cursor: Javascript-info notes (PATH)"
  elif [[ -f "$CURSOR_WIN" ]]; then
    "$CURSOR_WIN" "$JS_INFO" || true
    echo "Cursor: Javascript-info notes ($CURSOR_WIN)"
  else
    echo "Cursor not found. Install Cursor and add 'cursor' to PATH, or install to: $CURSOR_WIN" >&2
  fi

  if [[ -f "$OBSIDIAN_WIN" ]]; then
    "$OBSIDIAN_WIN" &
    echo "Obsidian launched."
  else
    echo "Obsidian not found at $OBSIDIAN_WIN" >&2
  fi
}

launch_native_linux() {
  warn_missing_dir "$JS_INFO"

  if command -v cursor &>/dev/null; then
    cursor "$JS_INFO" || true
    echo "Cursor: Javascript-info notes"
  else
    echo "cursor CLI not on PATH (native Linux)" >&2
    command -v xdg-open &>/dev/null || { echo "Install cursor or xdg-utils for xdg-open." >&2; exit 1; }
    xdg-open "$JS_INFO" 2>/dev/null || true
    echo "Fallback: file manager (xdg-open) - install Cursor for the intended workspace."
  fi

  if command -v obsidian &>/dev/null; then
    obsidian &
    echo "Obsidian (Linux) launched."
  elif command -v flatpak &>/dev/null && flatpak info md.obsidian.Obsidian &>/dev/null; then
    flatpak run md.obsidian.Obsidian &
    echo "Obsidian (Flatpak) launched."
  else
    echo "Install Obsidian for Linux or use the WSL script from WSL." >&2
  fi
}

if is_wsl; then
  if [[ ! -d "/mnt/c" ]]; then
    echo "/mnt/c not available - start WSL from Windows or enable interop." >&2
    exit 1
  fi
  launch_wsl
else
  echo "Not running under WSL - using native Linux fallbacks (edit paths below if needed)." >&2
  launch_native_linux
fi
