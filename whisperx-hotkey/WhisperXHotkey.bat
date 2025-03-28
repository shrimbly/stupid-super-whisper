@echo off
echo Starting WhisperX Hotkey...

:: Check if AutoHotkey is installed
where /q AutoHotkey.exe
if %ERRORLEVEL% neq 0 (
    echo AutoHotkey is not installed or not in your PATH.
    echo Please install AutoHotkey from https://www.autohotkey.com/
    echo.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)

:: Run the AutoHotkey script
start "" "AutoHotkey.exe" "%~dp0WhisperXHotkey.ahk"

echo WhisperX Hotkey is now running in the background.
echo Press Ctrl+Shift+Space to start recording, and release to transcribe.
echo.
echo You can close this window. 