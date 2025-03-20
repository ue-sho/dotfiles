{ config, lib, pkgs, ... }:

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
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      dock = {
        autohide = true;
        orientation = "bottom";
        showhidden = true;
        mru-spaces = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };
    };
    keyboard = {
      enableKeyMapping = true;
    };
  };

  # 基本的なシステムパッケージ
  environment.systemPackages = with pkgs; [
    coreutils
    gnused
    gnutar
    gnugrep
  ];

  # Nixのパス設定
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Homebrewの設定 (必要に応じて)
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    global.brewfile = true;
  };

  # サービス
  services = {
    nix-daemon.enable = true;
  };

  # プログラム
  programs = {
    zsh.enable = true;
  };
}