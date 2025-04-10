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
  deno

  # Database Related
  postgresql_17
  flyway

  # Additional Tools
  terraform
  tflint
]