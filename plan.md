# WhisperX Hotkey Transcription Development Plan

## Overview
This project integrates WhisperX speech recognition with Hammerspoon on macOS to enable hotkey-triggered transcription. Users can place their cursor in any text field, hold a hotkey, speak, and have their speech automatically transcribed and inserted upon release.

## Phase 1: Environment Setup (1-2 days)

1. **Install Base Requirements**
   - Install Hammerspoon (`brew install hammerspoon`)
   - Set up Python environment for WhisperX
   - Configure WhisperX with appropriate models
   - Test basic WhisperX functionality on short audio clips

2. **Project Structure**
   ```
   whisperx-hotkey/
   ├── setup.sh              # Installation script
   ├── config.json           # Configuration file
   ├── hammerspoon/
   │   └── init.lua          # Hammerspoon configuration
   ├── scripts/
   │   ├── transcribe.py     # WhisperX wrapper
   │   └── audio_utils.py    # Audio recording/processing
   └── README.md             # Documentation
   ```

## Phase 2: Core Components (3-4 days)

1. **Audio Recording Module**
   - Create Lua function to record audio while hotkey is pressed
   - Implement start/stop recording functionality
   - Save audio to temporary file
   - Add audio level monitoring for quality assurance

2. **WhisperX Integration**
   - Create Python script to process audio with WhisperX
   - Optimize for short recordings (reduce initialization time)
   - Add language detection/selection options
   - Implement model caching to reduce startup time

3. **Text Insertion Mechanism**
   - Implement clipboard-based text insertion
   - Handle different text field compatibility
   - Add optional formatting features

## Phase 3: Integration (2-3 days)

1. **Hotkey Configuration**
   - Create customizable hotkey binding in Hammerspoon
   - Add modifier key support (CMD, ALT, CTRL, etc.)
   - Support for alternative key combinations

2. **Pipeline Integration**
   - Connect recording → transcription → insertion workflow
   - Add error handling and status feedback
   - Implement timeout protection
   - Create logging system for debugging

3. **Performance Optimization**
   - Pre-load WhisperX models for faster transcription
   - Optimize audio format for quality/speed balance
   - Minimize latency in the full pipeline
   - Implement memory management for long-term usage

## Phase 4: User Experience (2 days)

1. **Status Indicators**
   - Add visual feedback during recording (menubar icon)
   - Create notifications for completion/errors
   - Optional sound effects for start/stop recording

2. **Configuration Interface**
   - Develop simple configuration options (hotkey, language, model size)
   - Store user preferences in config.json
   - Add ability to customize transcription parameters

3. **Installation Script**
   - Create one-click setup script
   - Handle dependencies installation
   - Add version checking and update functionality

## Phase 5: Testing & Refinement (2-3 days)

1. **Cross-Application Testing**
   - Test in various text fields (browsers, word processors, notes apps)
   - Verify compatibility with different keyboard layouts
   - Test with different Mac hardware configurations

2. **Performance Testing**
   - Measure transcription latency
   - Optimize resource usage
   - Battery impact analysis

3. **User Testing**
   - Gather feedback on usability
   - Address edge cases
   - Implement feature requests where appropriate

## Phase 6: Documentation & Distribution (1-2 days)

1. **Documentation**
   - Create comprehensive README
   - Add setup instructions and troubleshooting guide
   - Create usage examples and GIF demonstrations

2. **Package for Distribution**
   - Create release package
   - Add version control
   - Publish to appropriate channels (GitHub, etc.)

## Timeline Summary
- Total estimated time: 11-16 days
- Core functionality (Phases 1-3): 6-9 days
- Refinement and distribution (Phases 4-6): 5-7 days

## Required Skills
- Lua scripting (Hammerspoon)
- Python development
- Audio processing
- macOS system integration

## Success Metrics
- Transcription latency under 2 seconds for 10-second recordings
- Compatibility with 90%+ of common text input fields
- Reliable operation across different macOS versions (Monterey and newer)
- Memory footprint under 500MB during idle state

## Next Steps After Initial Release
- Create installer package (.pkg) for easier distribution
- Add support for specialized vocabulary/domain-specific models
- Implement continuous recording mode with automatic segmentation
- Explore integration with other speech recognition backends 