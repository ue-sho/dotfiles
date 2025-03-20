{ system, username, pkgs, casks ? [], ... }:

{
  nixpkgs.hostPlatform = system;
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Homebrewの基本設定
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";
    };
    casks = casks;
  };

  # システム設定
  system = {
    stateVersion = 4;

    defaults = {
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      LaunchServices.LSQuarantine = false;
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
        show-recents = false;
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = true;
      };
      trackpad = {
        Clicking = true;
        Dragging = true;
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

  # プログラム
  programs = {
    zsh.enable = true;
  };

  # ホームマネージャー設定
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # セキュリティ設定
  security = {
    sudo.extraConfig = ''
      ${username} ALL=(ALL) NOPASSWD: ALL
    '';
    pam.services.sudo_local.touchIdAuth = true;
  };
}