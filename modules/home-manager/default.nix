# Home Manager Configuration
{ config, pkgs, ... }:

# Home Manager Core Settings
{
  # XDG Base Directory Settings
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    cacheHome = "${config.home.homeDirectory}/.cache";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # Basic Home Directory Settings
  home.stateVersion = "23.11";

  # Common Packages
  home.packages = with pkgs; [
    # Basic Tools
    git
    vim
    curl
    wget
    jq
    ripgrep
    fd
    htop
  ];

  # Symlink Configuration Files
  home.file = let
    dotfilesPath = "${config.home.homeDirectory}/develop/uesho-yukyu-dev/dotfiles";
  in {
    "${config.xdg.configHome}/git".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/git";
    "${config.xdg.configHome}/vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/vim";
    "${config.xdg.configHome}/zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zsh";
  };
}