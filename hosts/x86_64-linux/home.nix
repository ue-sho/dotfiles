{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  # Linux固有の設定
  home = {
    username = "uesho";
    homeDirectory = "/home/uesho";
  };

  # Linux固有のパッケージ
  home.packages = with pkgs; [
    # Linuxツール
  ];

  # その他のLinux固有の設定
}