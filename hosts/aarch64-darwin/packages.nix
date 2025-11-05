{ pkgs, ... }:
let
  aqua = import ./aqua.nix { inherit pkgs; };
in
with pkgs; [
  # Basic Tools installed by modules/home-manager/default.nix

  # Programming Languages & SDKs
  kotlin
  jdk21
  gradle

  # Database Related
  postgresql_17
  flyway

  # Additional Tools
  awscli2
  go-task
  aqua  # Custom aqua package defined in aqua.nix
  mise
]
