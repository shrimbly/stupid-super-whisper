#!/bin/bash
# WhisperX Hotkey Setup Script

set -e  # Exit on error

# ANSI color codes for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_message() {
    echo -e "${BLUE}[WhisperX Hotkey]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install Homebrew first."
        echo "You can install Homebrew by running:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    else
        print_success "Homebrew is installed."
    fi
}

# Check if Python 3 is installed
check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Installing with Homebrew..."
        brew install python
    else
        print_success "Python 3 is installed."
    fi
}

# Check if pip3 is installed
check_pip() {
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 is not installed. Installing..."
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        python3 get-pip.py
        rm get-pip.py
    else
        print_success "pip3 is installed."
    fi
}

# Install Hammerspoon
install_hammerspoon() {
    if ! command -v hammerspoon &> /dev/null; then
        print_message "Installing Hammerspoon..."
        brew install --cask hammerspoon
    else
        print_success "Hammerspoon is already installed."
    fi
}

# Install Python dependencies
install_python_deps() {
    print_message "Installing Python dependencies..."
    
    # Create and activate virtual environment
    VENV_DIR="$HOME/whisperx-hotkey-env"
    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
        print_success "Created virtual environment at $VENV_DIR"
    fi
    
    # Activate virtual environment
    source "$VENV_DIR/bin/activate"
    
    # Upgrade pip
    pip3 install --upgrade pip
    
    # Install WhisperX and dependencies
    print_message "Installing WhisperX and dependencies..."
    pip3 install -U whisperx
    
    # Install audio processing libraries
    print_message "Installing audio processing libraries..."
    pip3 install soundfile numpy samplerate
    
    print_success "Python dependencies installed successfully."
}

# Setup Hammerspoon configuration
setup_hammerspoon() {
    HAMMERSPOON_DIR="$HOME/.hammerspoon"
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create Hammerspoon directory if it doesn't exist
    if [ ! -d "$HAMMERSPOON_DIR" ]; then
        mkdir -p "$HAMMERSPOON_DIR"
    fi
    
    # Copy the init.lua script
    print_message "Setting up Hammerspoon configuration..."
    cp "$SCRIPT_DIR/hammerspoon/init.lua" "$HAMMERSPOON_DIR/init.lua"
    
    # Create a symlink to the config file in the Hammerspoon resources
    ln -sf "$SCRIPT_DIR/config.json" "$HAMMERSPOON_DIR/whisperx_config.json"
    
    print_success "Hammerspoon configuration set up successfully."
}

# Create temp directories
create_temp_dirs() {
    TEMP_DIR="/tmp/whisperx-hotkey"
    if [ ! -d "$TEMP_DIR" ]; then
        mkdir -p "$TEMP_DIR"
        print_success "Created temporary directory at $TEMP_DIR"
    fi
}

# Main function
main() {
    print_message "Starting WhisperX Hotkey setup..."
    
    # Check requirements
    check_homebrew
    check_python
    check_pip
    
    # Install dependencies
    install_hammerspoon
    install_python_deps
    
    # Setup configuration
    setup_hammerspoon
    create_temp_dirs
    
    print_message "Setting file permissions..."
    chmod +x "$SCRIPT_DIR/scripts/transcribe.py"
    chmod +x "$SCRIPT_DIR/scripts/audio_utils.py"
    
    print_success "WhisperX Hotkey setup completed successfully!"
    print_message "Please reload Hammerspoon configuration or restart Hammerspoon to apply changes."
    print_message "Default hotkey: CMD+SHIFT+SPACE"
    
    # Remind user to set up permissions
    print_warning "IMPORTANT: You need to grant Hammerspoon permissions for:"
    echo "1. Accessibility (System Settings → Privacy & Security → Accessibility)"
    echo "2. Input Monitoring (System Settings → Privacy & Security → Input Monitoring)"
    echo "3. Microphone access (System Settings → Privacy & Security → Microphone)"
    
    # Open System Preferences to the relevant pages
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
}

# Run the script
main 