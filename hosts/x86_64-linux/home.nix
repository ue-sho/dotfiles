{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home-manager/home.nix
  ];

  home = {
    username = "uesho";
    homeDirectory = "/home/uesho";
  };

  home.packages = with pkgs; [
  ];
}