{ inputs }:
let
  inherit (inputs) nix-darwin home-manager nixpkgs;

  system = "aarch64-darwin";
  username = "shohei.ueda";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  # {{{ Homebrew taps
  taps = [
  ];
  # }}}

  # {{{ Homebrew brews (formulae)
  brews = [
    # Ruby のビルドに必要 (mise で ruby を入れる際の依存)
    "libyaml"
    "openssl@3"
    "xz"
    "readline"

    "typst"
  ];
  # }}}

  # {{{ Homebrew casks
  casks = [
    "visual-studio-code"
    "iterm2"
    "google-japanese-ime"
    "gcloud-cli"
    "obsidian"
    "rancher"
    "meetingbar"
    "raycast"
    "notion"
    "box-drive"
    "karabiner-elements"
    "postman"
    "cursor"
    "cmux"
    "1password"
    "zoom"
    "sequel-ace"

    # 以下は意図的に nix 管理外:
    #   Claude.app — 公式インストーラの自動更新に任せたいため宣言しない

    # "intellij-idea"
    # "webstorm"
    # "datagrip"
  ];
  # }}}
in
nix-darwin.lib.darwinSystem {
  modules = [
    home-manager.darwinModules.home-manager
    (import ../../modules/nix-darwin { inherit system username pkgs casks brews taps; })
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
