{ config, pkgs, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  homeDirectory = if isLinux then "/home/uesho" else "/Users/uesho";
in
{
  home.username = "uesho";
  home.homeDirectory = homeDirectory;
  home.stateVersion = "23.11";

  # XDG Base Directory の設定
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    cacheHome = "${config.home.homeDirectory}/.cache";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # パッケージのインストール
  home.packages = with pkgs; [
    git
    vim
    zsh
  ] ++ (if isLinux then [
    # Linux固有のパッケージ
  ] else if isDarwin then [
    # macOS固有のパッケージ
    cowsay
  ] else []);

  # 設定ファイルのシンボリックリンク（最初に設定）
  home.file = let
    dotfilesPath = "${config.home.homeDirectory}/develop/uesho-yukyu-dev/dotfiles";
  in {
    "${config.xdg.configHome}/git".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/git";
    "${config.xdg.configHome}/vim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/vim";
    "${config.xdg.configHome}/zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/config/zsh";
  };
}