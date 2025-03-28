# Stupid Super Whisper

> Speak anywhere, transcribe instantly.

Stupid Super Whisper is a Windows utility that enables quick speech-to-text anywhere with a simple keyboard shortcut. Hold down a hotkey, speak, and your words appear as text when you release the key.

## Features

- **Instant Transcription**: Speak and get accurate text with minimal delay
- **Global Hotkey**: Works in any application where text input is accepted
- **High Accuracy**: Powered by the state-of-the-art WhisperX speech recognition engine
- **Visual Feedback**: Clear indicators when recording is active
- **Customizable**: Configure hotkeys, language, and model settings

## Requirements

- Windows 10 or 11
- Python 3.8+
- [AutoHotkey](https://www.autohotkey.com/) (optional, but recommended)
- Microphone access

## Installation

### Automatic Installation

1. Clone this repository:
   ```
   git clone https://github.com/shrimbly/stupid-super-whisper.git
   cd stupid-super-whisper
   ```

2. Run the setup script by right-clicking `setup.ps1` and selecting "Run with PowerShell" or by opening PowerShell and running:
   ```powershell
   .\setup.ps1
   ```

3. Install AutoHotkey if prompted (download from https://www.autohotkey.com/)

4. Start using Stupid Super Whisper with the default shortcut: `CTRL+SHIFT+SPACE`

### Manual Installation

1. Install Python and pip
2. Install AutoHotkey from https://www.autohotkey.com/
3. Install WhisperX and dependencies:
   ```powershell
   pip install whisperx soundfile numpy samplerate
   ```

4. Create a temporary directory:
   ```powershell
   mkdir -p $env:TEMP\stupid-super-whisper
   ```

5. Double-click the `StupidSuperWhisper.ahk` script or run the `StupidSuperWhisper.bat` file

## Usage

1. Place your cursor where you want the transcribed text to appear
2. Press and hold `CTRL+SHIFT+SPACE` (default hotkey)
3. Speak clearly
4. Release the hotkey
5. Your speech will be transcribed and inserted at the cursor position

## Configuration

Edit the `config.json` file to customize the behavior:

```json
{
  "hotkey": {
    "key": "space",
    "modifiers": ["ctrl", "shift"]
  },
  "whisperx": {
    "model": "base",
    "compute_type": "int8",
    "language": "en",
    "batch_size": 16
  },
  "audio": {
    "sample_rate": 16000,
    "channels": 1,
    "format": "wav",
    "temp_dir": "%TEMP%\\stupid-super-whisper"
  },
  "ui": {
    "show_notifications": true,
    "play_sounds": true
  }
}
```

### Available WhisperX Models

- `tiny`: Smallest model, fastest but least accurate
- `base`: Good balance between speed and accuracy for short phrases
- `small`: More accurate but slower
- `medium`: Even more accurate but slower
- `large-v2`: Most accurate but slowest

After changing configuration, restart the AutoHotkey script.

## Troubleshooting

### Common Issues

**Transcription doesn't start**: 
- Ensure AutoHotkey is running
- Check if the microphone is working correctly
- Make sure the Python environment is properly set up

**Text is not inserted**:
- Some applications may block programmatic text insertion
- Try using the clipboard-based insertion method (default)

**Poor transcription quality**:
- Speak clearly and at a moderate pace
- Try using a larger model (small, medium, or large-v2)
- Reduce background noise

### Logs

The transcription script writes logs to stderr which you can view by running the script manually:

```powershell
python scripts/transcribe.py --audio_file test.wav
```

## License

MIT

## Credits

- [WhisperX](https://github.com/m-bain/whisperX) for the speech recognition engine
- [AutoHotkey](https://www.autohotkey.com/) for the Windows automation framework 