# Stupid Super Whisper Setup Script
Write-Host "Setting up Stupid Super Whisper..."

# Check if Python is installed
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python is not installed. Please install Python 3.8 or later from https://www.python.org/downloads/"
    exit 1
}

# Check if AutoHotkey is installed
if (-not (Test-Path "C:\Program Files\AutoHotkey\AutoHotkey.exe")) {
    Write-Host "AutoHotkey is not installed. Downloading..."
    $url = "https://www.autohotkey.com/download/ahk-v2.exe"
    $output = "$env:TEMP\AutoHotkey_Setup.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    Write-Host "Installing AutoHotkey..."
    Start-Process -FilePath $output -Wait
    Remove-Item $output
}

# Install Python dependencies
Write-Host "Installing Python dependencies..."
pip install whisperx soundfile numpy samplerate

# Create temp directory
$tempDir = "$env:TEMP\stupid-super-whisper"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

Write-Host "Setup complete! You can now run StupidSuperWhisper.bat to start the application." 