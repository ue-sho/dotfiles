{ pkgs, ... }:
with pkgs; [
  # Basic Tools installed by modules/home-manager/default.nix

  # Programming Languages & SDKs
  volta  # for node.js / pnpm
  python312
  kotlin
  jdk21
  gradle
  go

  # Database Related
  mysql80
  postgresql_15
  mongodb-tools

  # Container Tools
  kubectl
  minikube
  kubernetes-helm
  kustomize
  kubectx

  # Additional Tools
  graphviz
  shellcheck
  peco
]