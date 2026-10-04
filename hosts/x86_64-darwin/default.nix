{ inputs }:
let
  inherit (inputs) nix-darwin home-manager nixpkgs;

  system = "x86_64-darwin";
  username = "uesho";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  # {{{ Homebrew casks
  casks = [
    "discord"
    "visual-studio-code"
    "slack"
    "iterm2"
    "rectangle"
    "aws-vault-binary"
    "font-jetbrains-mono-nerd-font"
    "font-sauce-code-pro-nerd-font"
    "google-japanese-ime"
    "karabiner-elements"
    "gcloud-cli"
    "obsidian"
    "rancher"
    "meetingbar"
    "raycast"
    "cursor"
    "cmux"
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
