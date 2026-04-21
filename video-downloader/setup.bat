@echo off
echo ============================================
echo   Video Downloader - Setup
echo ============================================
echo.

echo [1/3] Installing / upgrading yt-dlp ...
pip install -U yt-dlp
echo.

echo [2/3] Checking ffmpeg ...
where ffmpeg >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [!] ffmpeg NOT found.
    echo.
    echo     ffmpeg is needed to merge video+audio into one file.
    echo     Without it you may get video-only or audio-only downloads.
    echo.
    echo     Option A - Install via winget (recommended):
    echo       winget install Gyan.FFmpeg
    echo.
    echo     Option B - Install via pip:
    echo       pip install imageio-ffmpeg
    echo.
    echo     Option C - Manual download:
    echo       https://ffmpeg.org/download.html
    echo       Extract and add the bin folder to your PATH.
    echo.
    set /p INSTALL_FFMPEG="Try installing via winget now? [y/N]: "
    if /i "!INSTALL_FFMPEG!"=="y" (
        winget install Gyan.FFmpeg
    )
) else (
    echo [+] ffmpeg is already installed.
)
echo.

echo [3/3] Creating downloads folder ...
if not exist "%~dp0downloads" mkdir "%~dp0downloads"
echo.

echo ============================================
echo   Setup complete!
echo.
echo   Usage:
echo     python download.py                     (interactive)
echo     python download.py [URL]               (download all)
echo     python download.py [URL] --list        (list videos)
echo     python download.py [URL] --pick 1,3,5  (pick specific)
echo.
echo   Or double-click: run.bat
echo ============================================
pause
