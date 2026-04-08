#!/usr/bin/env bash
# Mirrors open-sudheerj-javascript-interview-questions.ps1:
# - VS Code: Telegram-export markdown
# - Cursor: JavaScript notes workspace
# - Obsidian
# - Chrome: sudheerj/javascript-interview-questions README (TOC), Profile 4 (edit CHROME_PROFILE)
#
# Usage (WSL, from repo folder):
#   chmod +x open-sudheerj-javascript-interview-questions.sh
#   ./open-sudheerj-javascript-interview-questions.sh
#
# Optional: export WIN_USER=YourWindowsUser

set -uo pipefail

WIN_USER="${WIN_USER:-Avadhut}"
BASE="/mnt/c/Users/${WIN_USER}"

# Same URLs / profile intent as the .ps1 (edit CHROME_PROFILE to match Chrome)
CHROME_PROFILE="${CHROME_PROFILE:-Profile 4}"
SUDHEERJ_README_URL='https://github.com/sudheerj/javascript-interview-questions?tab=readme-ov-file#table-of-contents'

TELEGRAM_MD="${BASE}/Downloads/Telegram Desktop/sudheerjjavascript interview questions.md"
JS_WORKSPACE="${BASE}/Desktop/OfficeDataGDriveSync/Obsidean/Avadhut Notes FolderSync/Avadhut Notes Google Drive/1. Web Development/3. JavaScript"

CODE_WIN="${BASE}/AppData/Local/Programs/Microsoft VS Code/Code.exe"
CODE_WIN_ALT="/mnt/c/Program Files/Microsoft VS Code/Code.exe"
CURSOR_WIN="${BASE}/AppData/Local/Programs/cursor/Cursor.exe"
OBSIDIAN_WIN="${BASE}/AppData/Local/Obsidian/Obsidian.exe"
CHROME_WIN="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"

is_wsl() {
  [[ -f /proc/version ]] && grep -qiE 'microsoft|wsl' /proc/version
}

warn_missing() {
  local p="$1"
  if [[ ! -e "$p" ]]; then
    echo "Warning: path not found: $p" >&2
  fi
}

launch_wsl() {
  if [[ ! -d "/mnt/c" ]]; then
    echo "/mnt/c not available - start WSL from Windows or enable interop." >&2
    exit 1
  fi

  warn_missing "$TELEGRAM_MD"
  warn_missing "$JS_WORKSPACE"

  # VS Code: open file
  if command -v code &>/dev/null; then
    code "$TELEGRAM_MD" || true
    echo "VS Code: Telegram .md (PATH: code)"
  elif [[ -f "$CODE_WIN" ]]; then
    "$CODE_WIN" "$TELEGRAM_MD" || true
    echo "VS Code: Telegram .md ($CODE_WIN)"
  elif [[ -f "$CODE_WIN_ALT" ]]; then
    "$CODE_WIN_ALT" "$TELEGRAM_MD" || true
    echo "VS Code: Telegram .md ($CODE_WIN_ALT)"
  else
    echo "VS Code not found. Install VS Code or add 'code' to PATH." >&2
  fi

  # Cursor: JS workspace folder
  if command -v cursor &>/dev/null; then
    cursor "$JS_WORKSPACE" || true
    echo "Cursor: JavaScript notes (PATH)"
  elif [[ -f "$CURSOR_WIN" ]]; then
    "$CURSOR_WIN" "$JS_WORKSPACE" || true
    echo "Cursor: JavaScript notes ($CURSOR_WIN)"
  else
    echo "Cursor not found. Install Cursor and add 'cursor' to PATH, or: $CURSOR_WIN" >&2
  fi

  if [[ -f "$OBSIDIAN_WIN" ]]; then
    "$OBSIDIAN_WIN" &
    echo "Obsidian launched."
  else
    echo "Obsidian not found at $OBSIDIAN_WIN" >&2
  fi

  if [[ -f "$CHROME_WIN" ]]; then
    "$CHROME_WIN" --profile-directory="$CHROME_PROFILE" "$SUDHEERJ_README_URL" &
    echo "Chrome: $SUDHEERJ_README_URL (profile: $CHROME_PROFILE)"
  else
    echo "Chrome not found at $CHROME_WIN" >&2
  fi
}

launch_native_linux() {
  echo "Not WSL - native Linux fallbacks (edit paths if needed)." >&2

  warn_missing "$TELEGRAM_MD"
  warn_missing "$JS_WORKSPACE"

  if command -v code &>/dev/null; then
    code "$TELEGRAM_MD" || true
  else
    echo "Install VS Code or add 'code' to PATH." >&2
  fi

  if command -v cursor &>/dev/null; then
    cursor "$JS_WORKSPACE" || true
  else
    echo "cursor CLI not on PATH" >&2
  fi

  if command -v obsidian &>/dev/null; then
    obsidian &
  elif command -v flatpak &>/dev/null && flatpak info md.obsidian.Obsidian &>/dev/null; then
    flatpak run md.obsidian.Obsidian &
  else
    echo "Obsidian not found (Linux)." >&2
  fi

  if command -v google-chrome &>/dev/null; then
    google-chrome --profile-directory="$CHROME_PROFILE" "$SUDHEERJ_README_URL" &
    echo "Chrome (google-chrome): $SUDHEERJ_README_URL"
  elif command -v chromium &>/dev/null; then
    chromium --profile-directory="$CHROME_PROFILE" "$SUDHEERJ_README_URL" &
    echo "Chromium: $SUDHEERJ_README_URL"
  elif command -v xdg-open &>/dev/null; then
    xdg-open "$SUDHEERJ_README_URL" &
    echo "Fallback: xdg-open URL (no profile selection)"
  fi
}

if is_wsl; then
  launch_wsl
else
  # On pure Linux, paths above assume /mnt/c - use native paths if you copy notes locally
  launch_native_linux
fi

echo "Done."
