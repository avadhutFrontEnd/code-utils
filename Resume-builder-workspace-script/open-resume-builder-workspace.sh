#!/usr/bin/env bash
# Opens resume-builder + Tier 1 Companies notes in two Cursor windows (two workspaces, WSL),
# and Windows Obsidian - mirrors open-resume-builder-workspace.ps1.
#
# Usage (WSL):
#   chmod +x open-resume-builder-workspace.sh
#   ./open-resume-builder-workspace.sh
#
# Optional: export WIN_USER=YourWindowsUser   if your Windows profile name ≠ Linux default below

set -uo pipefail

WIN_USER="${WIN_USER:-Avadhut}"
BASE="/mnt/c/Users/${WIN_USER}"

RESUME="${BASE}/Desktop/git/tier-1-company-projects/resume-builder"
TIER1="${BASE}/Desktop/OfficeDataGDriveSync/Obsidean/Avadhut Notes FolderSync/Avadhut Notes Google Drive/1. Web Development/Tier 1 Companies Project"
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
  warn_missing_dir "$RESUME"
  warn_missing_dir "$TIER1"

  # Cursor (Windows): one window per folder - two separate workspaces
  if command -v cursor &>/dev/null; then
    cursor "$RESUME" || true
    cursor "$TIER1" || true
    echo "Cursor: two windows - resume-builder, Tier 1 Companies Project (PATH)"
  elif [[ -f "$CURSOR_WIN" ]]; then
    "$CURSOR_WIN" "$RESUME" || true
    "$CURSOR_WIN" "$TIER1" || true
    echo "Cursor: two windows - resume-builder, Tier 1 Companies Project ($CURSOR_WIN)"
  else
    echo "Cursor not found. Install Cursor and add 'cursor' to PATH, or install to: $CURSOR_WIN" >&2
  fi

  # Obsidian (Windows)
  if [[ -f "$OBSIDIAN_WIN" ]]; then
    "$OBSIDIAN_WIN" &
    echo "Obsidian launched."
  else
    echo "Obsidian not found at $OBSIDIAN_WIN" >&2
  fi
}

launch_native_linux() {
  warn_missing_dir "$RESUME"
  warn_missing_dir "$TIER1"

  if command -v cursor &>/dev/null; then
    cursor "$RESUME" || true
    cursor "$TIER1" || true
    echo "Cursor: two windows - resume-builder, Tier 1 Companies Project"
  else
    echo "cursor CLI not on PATH (native Linux)" >&2
    command -v xdg-open &>/dev/null || { echo "Install cursor or xdg-utils for xdg-open." >&2; exit 1; }
    xdg-open "$RESUME" 2>/dev/null || true
    xdg-open "$TIER1" 2>/dev/null || true
    echo "Fallback: file manager (xdg-open) - install Cursor for two workspaces."
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
