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

Before diving into Nix, you'll need to prepare your system.

- Run the Pre-installation Script:
    - Execute the `pre-install.sh` script located in the root of this repository.
    - This script handles essential setup like XDG Base Directory configuration, Homebrew installation (on macOS), and Zinit installation.
    ```bash
    ./pre-install.sh
    ```
- Install Determinate Nix:
    - It's recommended to install [Determinate Nix](https://determinate.systems/nix/) on macOS.
    - Determinate Nix provides a robust and reliable installation of Nix, ensuring better compatibility and a smoother experience when managing your dotfiles with Nix flakes on your Mac.

### Installation

#### macOS with nix-darwin

For Intel Mac:
```bash
sudo nix run github:LnL7/nix-darwin -- switch --flake .#intel-mac
```

For Apple Silicon Mac:
```bash
sudo nix run github:LnL7/nix-darwin -- switch --flake .#arm-mac
```

#### Linux or Standalone home-manager (macOS)

```bash
nix run --experimental-features 'nix-command flakes' .#home-manager -- switch --flake .#linux
```

## References

- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Determinate Nix](https://determinate.systems/nix/)
- [Nix Packages Search](https://search.nixos.org/packages)
