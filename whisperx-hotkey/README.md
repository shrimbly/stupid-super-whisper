# Stupid Super Whisper

> Speak anywhere, transcribe instantly.

Stupid Super Whisper is a macOS utility that enables quick speech-to-text anywhere with a simple keyboard shortcut. Hold down a hotkey, speak, and your words appear as text when you release the key.

## Features

- **Instant Transcription**: Speak and get accurate text with minimal delay
- **Global Hotkey**: Works in any application where text input is accepted
- **High Accuracy**: Powered by the state-of-the-art WhisperX speech recognition engine
- **Visual Feedback**: Clear indicators when recording is active
- **Customizable**: Configure hotkeys, language, and model settings

## Requirements

- macOS 10.15 (Catalina) or later
- Python 3.8+
- [Homebrew](https://brew.sh) package manager
- [Hammerspoon](https://www.hammerspoon.org/) for macOS automation
- Microphone access

## Installation

### Automatic Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/shrimbly/stupid-super-whisper.git
   cd stupid-super-whisper
   ```

2. Make the setup script executable and run it:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   **Note:** If you don't have sudo permissions, the script will guide you through alternative installation methods.

3. Grant necessary permissions to Hammerspoon when prompted:
   - Accessibility (System Settings → Privacy & Security → Accessibility)
   - Input Monitoring (System Settings → Privacy & Security → Input Monitoring)
   - Microphone access (System Settings → Privacy & Security → Microphone)

4. Start using Stupid Super Whisper with the default shortcut: `CMD+SHIFT+SPACE`

### Manual Installation

1. Install Homebrew if not already installed:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

   **Alternative (no sudo required):**
   - If you don't have sudo permissions, you can install Homebrew in a custom location:
   ```bash
   mkdir -p ~/homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/homebrew
   export PATH=$HOME/homebrew/bin:$PATH
   echo 'export PATH=$HOME/homebrew/bin:$PATH' >> ~/.zshrc  # or ~/.bash_profile
   ```

2. Install Hammerspoon:
   ```bash
   brew install --cask hammerspoon
   ```

   **Alternative (no sudo required):**
   - Download Hammerspoon directly from [https://github.com/Hammerspoon/hammerspoon/releases/latest](https://github.com/Hammerspoon/hammerspoon/releases/latest)
   - Extract the .zip file
   - Drag Hammerspoon.app to your Applications folder (or any folder you have write access to)
   - Launch Hammerspoon from your Applications folder

3. Create a Python virtual environment and install dependencies:
   ```bash
   python3 -m venv ~/whisperx-hotkey-env
   source ~/whisperx-hotkey-env/bin/activate
   pip3 install -U whisperx soundfile numpy samplerate
   ```

4. Create necessary directories and setup Hammerspoon configuration:
   ```bash
   mkdir -p ~/.hammerspoon
   mkdir -p /tmp/whisperx-hotkey
   cp hammerspoon/init.lua ~/.hammerspoon/
   ln -sf "$(pwd)/config.json" ~/.hammerspoon/whisperx_config.json
   ```

## Usage

1. Place your cursor where you want the transcribed text to appear
2. Press and hold `CMD+SHIFT+SPACE` (default hotkey)
3. Speak clearly
4. Release the hotkey
5. Your speech will be transcribed and inserted at the cursor position

## Configuration

Edit the `config.json` file to customize the behavior:

```json
{
  "hotkey": {
    "key": "space",
    "modifiers": ["cmd", "shift"]
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
    "temp_dir": "/tmp/whisperx-hotkey"
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

After changing configuration, reload Hammerspoon configuration (click the Hammerspoon menubar icon and select "Reload Config").

## Troubleshooting

### Common Issues

**Transcription doesn't start**: 
- Ensure Hammerspoon is running and has proper permissions
- Check if the microphone is working and has permissions
- Make sure the Python virtual environment is activated

**Text is not inserted**:
- Some applications may block programmatic text insertion
- Check Hammerspoon's accessibility permissions
- Try using the clipboard-based insertion method (default)

**Poor transcription quality**:
- Speak clearly and at a moderate pace
- Try using a larger model (small, medium, or large-v2)
- Reduce background noise

### Logs

Check Hammerspoon's console for logs (click the Hammerspoon menubar icon and select "Console").

You can also view transcription logs by running the script manually:

```bash
source ~/whisperx-hotkey-env/bin/activate
python3 scripts/transcribe.py --audio_file test.wav
```

## License

MIT

## Credits

- [WhisperX](https://github.com/m-bain/whisperX) for the speech recognition engine
- [Hammerspoon](https://www.hammerspoon.org/) for the macOS automation framework