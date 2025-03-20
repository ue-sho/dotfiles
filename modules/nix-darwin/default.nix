{ config, pkgs, ... }:

{
  # Nix設定
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # システム設定
  system = {
    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
      };
      dock = {
        autohide = true;
        mru-spaces = false;
        show-recents = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
    };
  };

  # システムパッケージ
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    wget
  ];

  # サービス
  services = {
    nix-daemon.enable = true;
  };

  # プログラム
  programs = {
    zsh.enable = true;
  };
}