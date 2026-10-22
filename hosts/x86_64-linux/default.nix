{ inputs, ... }:
let
  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
    };
    overlays = [ (import ../../overlays/mise.nix) ];
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

        kotlin
        postgresql_17
        flyway

        # Container Tools
        # minikube も bin/kubectl (minikube 経由のシム) を同梱するため、本物の kubectl を優先させる
        (lib.hiPrio kubectl)
        minikube
        kubernetes-helm
        kustomize
        kubectx
        argocd
        kubeseal

        # Additional Tools
        graphviz
        shellcheck
        peco
      ];
    }
  ];
}