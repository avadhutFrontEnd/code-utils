#!/usr/bin/env bash
set -euo pipefail

workspaces=(
  "/mnt/c/Users/Avadhut/Desktop/git/4. Node/code"
  "/mnt/c/Users/Avadhut/Desktop/git/4. Node/NestJS"
  "/mnt/c/Users/Avadhut/Desktop/git/4. Node/Node Projects"
  "/mnt/c/Users/Avadhut/Desktop/git/4. Node/node-api"
)

if ! command -v cursor >/dev/null 2>&1; then
  echo "Cursor CLI command not found. Install/enable 'cursor' in PATH first."
  exit 1
fi

echo "Opening Cursor workspaces in separate windows..."

for ws in "${workspaces[@]}"; do
  if [[ ! -d "$ws" ]]; then
    echo "Skipping (folder not found): $ws"
    continue
  fi

  echo "Opening workspace folder in new window: $ws"
  cursor -n -- "$ws" >/dev/null 2>&1 &
  sleep 0.7
done

echo "Done: requested workspaces opened in separate Cursor windows."
