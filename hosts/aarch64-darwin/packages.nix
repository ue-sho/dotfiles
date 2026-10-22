{ pkgs, ... }:
with pkgs; [
  # Basic Tools installed by modules/home-manager/default.nix

  # Programming Languages & SDKs
  kotlin
  jdk21
  gradle

  # Database Related
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

  # Terraform Tools
  terraform-docs
  tflint

  # Additional Tools
  awscli2
  saml2aws
]
