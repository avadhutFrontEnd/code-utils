@echo off
setlocal enabledelayedexpansion

echo Opening Cursor workspaces in separate windows...

where cursor >nul 2>nul
if errorlevel 1 (
  echo Cursor CLI command not found. Install/enable "cursor" in PATH first.
  exit /b 1
)

call :openWorkspace "C:\Users\Avadhut\Desktop\git\4. Node\code"
call :openWorkspace "C:\Users\Avadhut\Desktop\git\4. Node\NestJS"
call :openWorkspace "C:\Users\Avadhut\Desktop\git\4. Node\Node Projects"
call :openWorkspace "C:\Users\Avadhut\Desktop\git\4. Node\node-api"

echo Done: requested workspaces opened in separate Cursor windows.
goto :eof

:openWorkspace
set "WS=%~1"
if not exist "%WS%\*" (
  echo Skipping (folder not found): %WS%
  goto :eof
)
echo Opening workspace folder in new window: %WS%
start "" cursor -n -- "%WS%"
timeout /t 1 /nobreak >nul
goto :eof