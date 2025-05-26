#!/bin/bash

# Set XDG Base Directory Specification variables
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"

# Create necessary directories
mkdir -p "${XDG_CONFIG_HOME}"
mkdir -p "${XDG_DATA_HOME}"
mkdir -p "${XDG_CACHE_HOME}"

echo "XDG_CONFIG_HOME set to ${XDG_CONFIG_HOME}"
echo "XDG_DATA_HOME set to ${XDG_DATA_HOME}"
echo "XDG_CACHE_HOME set to ${XDG_CACHE_HOME}"

# Install Homebrew only on macOS
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "Detected macOS. Checking for Homebrew installation..."
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        # Load Homebrew environment variables immediately for current script execution
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "Homebrew installation complete."
    else
        echo "Homebrew is already installed."
        # Ensure Homebrew environment variables are loaded even if already installed
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Not on macOS. Skipping Homebrew installation."
fi

# Install Zinit
if [ ! -d "${XDG_DATA_HOME}/zinit/bin" ]; then
    echo "Installing Zinit..."
    git clone "https://github.com/zdharma-continuum/zinit" "${XDG_DATA_HOME}/zinit/bin"
    echo "Zinit installation complete."
else
    echo "Zinit is already installed."
fi

echo "Ready to proceed with your Nix configuration."