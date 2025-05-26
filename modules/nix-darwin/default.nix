{ system, username, pkgs, casks ? [], ... }:

{
  # manage nix by nix determinate system
  nix.enable = false;

  nixpkgs.hostPlatform = system;
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    casks = casks;
  };

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

  environment.systemPackages = with pkgs; [
  ];

  programs = {
    zsh.enable = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  security = {
    sudo.extraConfig = ''
      ${username} ALL=(ALL) NOPASSWD: ALL
    '';
    pam.services.sudo_local.touchIdAuth = true;
  };
}