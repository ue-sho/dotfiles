{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  # Apple Silicon Mac固有の設定
  home = {
    username = "uesho";
    homeDirectory = "/Users/uesho";
  };

  # Apple Silicon Mac固有のパッケージ
  home.packages = with pkgs; [
    # ARM Mac特有のツール
  ];

  # その他のApple Silicon Mac固有の設定
}