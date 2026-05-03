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
  kubectl
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
  mise
]
