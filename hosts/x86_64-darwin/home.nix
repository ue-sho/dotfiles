{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  # Intel Mac固有の設定
  home = {
    username = "uesho";
    homeDirectory = "/Users/uesho";
  };

  # Intel Mac固有のパッケージ
  home.packages = with pkgs; [
    # Intel Mac特有のツール
  ];

  # その他のIntel Mac固有の設定
}