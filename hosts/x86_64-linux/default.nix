{ inputs, ... }:
let
  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs { inherit system; };
in
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    ../../modules/home-manager/default.nix

    {
      home = {
        username = "uesho";
        homeDirectory = "/home/uesho";
      };

      home.packages = with pkgs; [
        # Basic Tools installed by modules/home-manager/default.nix

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

        # Container Tools
        kubectl
        minikube
        kubernetes-helm
        kustomize
        kubectx

        # Additional Tools
        terraform
        graphviz
        shellcheck
        peco
      ];
    }
  ];
}