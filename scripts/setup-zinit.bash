#!/usr/bin/env bash
set -x
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"

# Check if zsh is installed, if not, install it.
if ! command -v zsh &>/dev/null; then
    echo "zsh is not installed. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update && sudo apt install -y zsh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install zsh
    else
        echo "Unsupported OS: $OSTYPE" >&2
        exit 1
    fi
fi

# Set zsh as the default shell if it is not already
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    echo "Changing the default shell to zsh..."
    chsh -s "$(command -v zsh)"
fi

if [ -d "$XDG_DATA_HOME/zinit/bin" ]; then
    echo "zinit is already installed."
    git -C "$XDG_DATA_HOME/zinit/bin" pull
else
    echo "Installing zinit..."
    git clone "https://github.com/zdharma-continuum/zinit" "$XDG_DATA_HOME/zinit/bin"
fi
