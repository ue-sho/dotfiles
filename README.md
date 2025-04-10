# Dotfiles

My personal dotfiles managed with Nix Flakes.

## Directory Structure

```
.
|-- config         # Actual configuration files
│   ├── zsh        # Zsh configuration
│   ├── git        # Git configuration
│   ├── vim        # Vim configuration
│   └── ...
|── hosts          # Host-specific configurations
│   ├── aarch64-darwin  # Apple Silicon Mac settings
│   ├── x86_64-darwin   # Intel Mac settings
│   ├── x86_64-linux    # Linux settings
|── modules        # Common modules
│   ├── nix-darwin       # nix-darwin common settings
│   ├── home-manager     # home-manager common settings
|--flake.nix       # Nix Flake configuration
```

## Setup

### Prerequisites

1. Install Nix
2. Enable Nix Flakes
3. Install zinit
    ```bash
    git clone "https://github.com/zdharma-continuum/zinit" "~/.config/zinit/bin"
    ```
4. Install brew for macOS
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    ```

### Installation

#### macOS with nix-darwin

For Intel Mac:
```bash
nix run --experimental-features 'nix-command flakes' github:LnL7/nix-darwin -- switch --flake .#intel-mac
```

For Apple Silicon Mac:
```bash
nix run --experimental-features 'nix-command flakes' github:LnL7/nix-darwin -- switch --flake .#arm-mac
```

#### Linux or Standalone home-manager (macOS)

```bash
home-manager switch --flake .#linux
```
