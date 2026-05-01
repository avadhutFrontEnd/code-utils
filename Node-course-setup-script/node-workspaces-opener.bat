@echo off
echo Opening Cursor Workspaces...

start "" "cursor" "C:\Users\Avadhut\Desktop\git\4. Node\code"
timeout /t 2 /nobreak >nul

start "" "cursor" "C:\Users\Avadhut\Desktop\git\4. Node\NestJS"
timeout /t 2 /nobreak >nul

start "" "cursor" "C:\Users\Avadhut\Desktop\git\4. Node\Node Projects"
timeout /t 2 /nobreak >nul

start "" "cursor" "C:\Users\Avadhut\Desktop\git\4. Node\node-api"
timeout /t 2 /nobreak >nul

echo All workspaces opened!
pause