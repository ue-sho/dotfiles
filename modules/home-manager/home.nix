{ config, lib, pkgs, ... }:

{
  # ホームマネージャー自体の設定
  programs.home-manager.enable = true;

  # XDG Base Directory の設定
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    cacheHome = "${config.home.homeDirectory}/.cache";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # 基本的なホームディレクトリ設定
  home.stateVersion = "23.11"; # バージョンは適宜変更してください

  # 共通のパッケージ
  home.packages = with pkgs; [
    # 基本ツール
    git
    vim
    curl
    wget
    jq
    ripgrep
    fd
    htop
  ];

  # 設定ファイルのシンボリックリンク（最初に設定）
  home.file = let
    dotfilesPath = "${config.home.homeDirectory}/develop/uesho-yukyu-dev/dotfiles";
  in {
    "${config.xdg.configHome}/git".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/git";
    "${config.xdg.configHome}/vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/vim";
    "${config.xdg.configHome}/zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zsh";
  };
}