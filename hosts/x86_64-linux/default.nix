# /home/uesho/dotfiles/hosts/x86_64-linux/default.nix
{ inputs, system, ... }: # system 引数を受け取るように変更
let
  # inputs.nixpkgs から pkgs を明示的に定義します
  # legacyPackages の代わりに import inputs.nixpkgs { inherit system; } を使います
  pkgs = import inputs.nixpkgs { inherit system; };
in
# Home Manager の設定全体を inputs.home-manager.lib.homeManagerConfiguration でラップします
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs; # 定義した pkgs 変数を Home Manager の設定に渡します

  modules = [
    # 既存の modules/home-manager/home.nix をインポートします
    # パスが誤っていたので、modules/home-manager/default.nix を指定します
    # または、より適切なパスがあればそれに変更してください
    ../../modules/home-manager/default.nix

    # このファイル内で定義していた Home Manager の設定をここに移動します
    {
      home = {
        username = "uesho";
        homeDirectory = "/home/uesho";
        # home.stateVersion は modules/home-manager/default.nix で定義されているため、
        # ここでは重複を避けるためにコメントアウトまたは削除します。
        # home.stateVersion = "24.05";
      };

      home.packages = with pkgs; [
        # Programming Languages & SDKs
        volta # for node.js / pnpm
        python312
        uv
        kotlin
        jdk21
        gradle
        go

        # Database Related
        postgresql_17
        flyway
      ];
    }
  ];
}