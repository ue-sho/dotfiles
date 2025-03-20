{ pkgs, ... }:
with pkgs; [
  # Basic Tools
  vim
  git
  gh
  ghq
  jq
  tree
  htop
  bat
  ripgrep
  fd
  fzf
  git-lfs
  gnupg
  wget
  curl
  gcc
  go
  nodejs_20
  python312
  ruby_3_2

  # GNU Commands
  coreutils
  findutils
  gnused
  gnugrep
  gnutar
  gawk

  # Development Tools
  gnumake
  direnv

  # Database Related
  mysql80
  postgresql_15
  mongodb-tools

  # Container Tools
  docker
  kubectl
  minikube
  kubernetes-helm
  kustomize
  kubectx

  # Additional Tools
  ffmpeg_6
  imagemagick
  graphviz
  shellcheck
  tig
  lazygit
  peco
  trash-cli
]