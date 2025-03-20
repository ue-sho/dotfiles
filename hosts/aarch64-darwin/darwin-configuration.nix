{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/nix-darwin/default.nix
  ];

  # ホスト名設定
  networking.hostName = "arm-mac";

  # Apple Silicon固有の設定
  system.defaults.NSGlobalDomain = {
    "com.apple.swipescrolldirection" = true;
  };

  # 特定のApple Silicon Mac向けパッケージ
  environment.systemPackages = with pkgs; [
    # ARM Mac特有のパッケージ
  ];

  # Apple Siliconで必要な追加設定

  # ホームマネージャー統合
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # ユーザー固有の設定をインポート（homeDirectoryは./home.nixで設定）
  home-manager.users.uesho = import ./home.nix;

  # システムバージョン
  system.stateVersion = 4;
}