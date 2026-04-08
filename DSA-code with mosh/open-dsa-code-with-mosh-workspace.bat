@echo off
cd /d "%~dp0"
REM Usage: double-click (prompts), or: open-dsa-code-with-mosh-workspace.bat 2
REM Or full param: open-dsa-code-with-mosh-workspace.bat -Topic 3
if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0open-dsa-code-with-mosh-workspace.ps1"
) else if "%~1"=="1" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0open-dsa-code-with-mosh-workspace.ps1" -Topic 1
) else if "%~1"=="2" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0open-dsa-code-with-mosh-workspace.ps1" -Topic 2
) else if "%~1"=="3" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0open-dsa-code-with-mosh-workspace.ps1" -Topic 3
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0open-dsa-code-with-mosh-workspace.ps1" %*
)
if errorlevel 1 pause
