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
  mise
]
