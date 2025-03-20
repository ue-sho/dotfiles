{
  description = "uesho's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      # スタンドアロンのHome Manager設定
      homeConfigurations = {
        # Linux configuration
        "uesho@ubuntu" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./hosts/x86_64-linux/home.nix ];
        };

        # Intel Mac configuration (スタンドアロン用)
        "uesho@intel-mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-darwin;
          modules = [ ./hosts/x86_64-darwin/home.nix ];
        };

        # Apple Silicon Mac configuration (スタンドアロン用)
        "uesho@arm-mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          modules = [ ./hosts/aarch64-darwin/home.nix ];
        };
      };

      # nix-darwin設定 (home-manager統合含む)
      darwinConfigurations = {
        # Intel Mac
        "intel-mac" = darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [
            ./hosts/x86_64-darwin/darwin-configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };

        # Apple Silicon Mac
        "arm-mac" = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/aarch64-darwin/darwin-configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };
      };
    };
}