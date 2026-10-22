# eMudhra 中間証明書問題 (2026-10) の修正版 mise (>= 2026.10.17) が nixpkgs に来るまでの一時 overlay。
# nixpkgs の mise が 2026.10.17 以上になったら、このファイルと modules/nix-darwin/default.nix・hosts/x86_64-linux/default.nix の overlays 行を削除する。
final: prev: {
  mise = prev.mise.overrideAttrs (finalAttrs: old: {
    # 2026.10.17 で増えた libz-ng-sys がビルド時に cmake を要求する
    nativeBuildInputs = old.nativeBuildInputs ++ [ prev.cmake ];
    version = "2026.10.17";
    src = prev.fetchFromGitHub {
      owner = "jdx";
      repo = "mise";
      tag = "v${finalAttrs.version}";
      hash = "sha256-3JBs2i+07hY27EpIrmbMu7D5p6rGV6wuerilx0BECjw=";
    };
    # overrideAttrs では cargoHash が vendor に伝播しないので cargoDeps ごと差し替える
    cargoDeps = prev.rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname version src;
      hash = "sha256-94BNmTVcJoY9ujO7boBzxMxaMy2tjLzpD+s+RLJxBEs=";
    };
    doCheck = false;
  });
}
