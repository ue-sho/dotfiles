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
  home.stateVersion = "24.11";

  # Common Packages
  home.packages = with pkgs; [
    # Basic Tools
    git
    vim
    curl
    wget
    jq
    fd
    htop
    gh
    yq
    tree
    bat
    git-lfs
    direnv
    yazi
  ];

  # Symlink Configuration Files
  home.file = let
    dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  in {
    "${config.xdg.configHome}/git".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/git";
    "${config.xdg.configHome}/vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/vim";
    "${config.xdg.configHome}/zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zsh";
    "${config.xdg.configHome}/mise".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/mise";
    "${config.xdg.configHome}/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/ghostty";
    "${config.xdg.configHome}/scripts".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/scripts";
    "${config.home.homeDirectory}/.zshenv".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/zsh/.zshenv";

    # Claude Code reads ~/.claude (not ~/.config). Link the reusable config:
    # settings + global instructions as files, skills/commands as whole dirs so
    # newly created skills land in dotfiles automatically. Volatile data
    # (history, sessions, cache, ...) stays out because only these paths link.
    "${config.home.homeDirectory}/.claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/claude/settings.json";
    "${config.home.homeDirectory}/.claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/claude/CLAUDE.md";
    "${config.home.homeDirectory}/.claude/skills".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/claude/skills";
  };
}