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
    "google-chrome"
    "discord"
    "visual-studio-code"
    "docker"
    "slack"
    "iterm2"
    "rectangle"
    "aws-vault"
    "bitwarden"
    "font-jetbrains-mono-nerd-font"
    "font-sauce-code-pro-nerd-font"
    "google-japanese-ime"
    "karabiner-elements"
    "warp"
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