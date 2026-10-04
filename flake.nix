# flake.nix
{
  description = "uesho's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs 26.11+ dropped x86_64-darwin; pin intel-mac to the last Darwin branch.
    nixpkgs-intel.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-intel = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin-intel = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-intel";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { system, inputs', ... }: {
        apps.home-manager = {
          type = "app";
          program = "${inputs'.home-manager.packages.home-manager}/bin/home-manager";
        };

        apps.default = {
          type = "app";
          program = "${inputs'.home-manager.packages.home-manager}/bin/home-manager";
        };
      };

      flake = {
        darwinConfigurations = {
          # Intel Mac
          "intel-mac" = import ./hosts/x86_64-darwin {
            inputs = inputs // {
              nixpkgs = inputs.nixpkgs-intel;
              nix-darwin = inputs.nix-darwin-intel;
              home-manager = inputs.home-manager-intel;
            };
          };

          # Apple Silicon Mac
          "arm-mac" = import ./hosts/aarch64-darwin { inherit inputs; };
        };

        # Linux
        homeConfigurations = {
          "linux" = import ./hosts/x86_64-linux { inherit inputs; };
        };
      };
    };
}