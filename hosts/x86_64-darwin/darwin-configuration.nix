{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/nix-darwin/default.nix
  ];

  # ホスト名設定
  networking.hostName = "intel-mac";

  # Intel Mac固有の設定
  system.defaults.NSGlobalDomain = {
    "com.apple.swipescrolldirection" = true;
  };

  # 特定のIntel Mac向けパッケージ
  environment.systemPackages = with pkgs; [
    # Intel Mac特有のパッケージ
  ];

  # Intel Macで必要な追加設定

  # ホームマネージャー統合
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # ユーザー固有の設定をインポート（homeDirectoryは./home.nixで設定）
  home-manager.users.uesho = import ./home.nix;

  # システムバージョン
  system.stateVersion = 4;
}