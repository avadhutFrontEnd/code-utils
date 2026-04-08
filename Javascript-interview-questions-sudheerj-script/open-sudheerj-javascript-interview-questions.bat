@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0open-sudheerj-javascript-interview-questions.ps1"
if errorlevel 1 pause
