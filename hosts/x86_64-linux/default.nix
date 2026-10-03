{ inputs, ... }:
let
  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
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
        python3
        uv
        kotlin
        go

        # Database Related
        postgresql_17
        flyway
        mysql

        # Container Tools
        kubectl
        minikube
        kubernetes-helm
        kustomize
        kubectx
        argocd
        kubeseal

        # Additional Tools
        terraform
        graphviz
        shellcheck
        peco
      ];
    }
  ];
}