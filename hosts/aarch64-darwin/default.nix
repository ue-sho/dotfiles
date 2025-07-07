{ inputs }:
let
  inherit (inputs) nix-darwin home-manager nixpkgs;

  system = "aarch64-darwin";
  username = "shohei.ueda";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  # {{{ Homebrew casks
  casks = [
    "visual-studio-code"
    "iterm2"
    "google-japanese-ime"
    "google-cloud-sdk"
    "obsidian"
    "rancher"
    "intellij-idea"
    "webstorm"
    "datagrip"
    "meetingbar"
    "raycast"
    "notion"
    "box-drive"
    "karabiner-elements"
    "postman"
    "cursor"
    "1password"
    "zoom"
  ];
  # }}}
in
nix-darwin.lib.darwinSystem {
  modules = [
    home-manager.darwinModules.home-manager
    (import ../../modules/nix-darwin { inherit system username pkgs casks; })
    {
      home-manager.backupFileExtension = "bk.nix";
      home-manager.users.${username} = {
        imports = [
          ../../modules/home-manager
        ];

        home.packages = import ./packages.nix { inherit pkgs; };
      };
    }
  ];
}
