# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Setup, install commands, and directory layout live in `README.md` — read it first. This file only covers what is **not obvious from the code**.

## Architecture in one paragraph

`hosts/<system>/default.nix` is the entry point per machine. It builds a `pkgs` (with `allowUnfree`), declares `casks` + `brews` lists, and composes the system from the two shared modules: `modules/nix-darwin` (system-level macOS settings + the homebrew block) and `modules/home-manager` (XDG dirs, common packages, and the symlink table from `config/<tool>` to `$XDG_CONFIG_HOME/<tool>`). Host-specific user packages go in `hosts/<system>/packages.nix`. The `nixpkgs.follows` wiring in `flake.nix` keeps home-manager and nix-darwin on a single nixpkgs revision.

Three machines, two shapes: macOS hosts (`arm-mac`, `intel-mac`) use **nix-darwin + home-manager**; the Linux host uses **standalone home-manager**. Determinate Nix is assumed on macOS (`nix.enable = false`).

## The two-speed config rule

Editing files under `config/` (zsh, git, vim, mise, gh) takes effect **immediately** — they're symlinked into `$XDG_CONFIG_HOME` via `mkOutOfStoreSymlink`. No rebuild needed.

Anything in `*.nix` (packages, casks, brews, system defaults) requires `nix run github:LnL7/nix-darwin -- switch --flake .#<host>` to apply.

If the user reports "I edited X but nothing changed," the question is which side of this line X is on.

## Where does a new tool go?

| What | Where |
| --- | --- |
| CLI from nixpkgs, used on every machine | `modules/home-manager/default.nix` `home.packages` |
| CLI from nixpkgs, only one host | `hosts/<system>/packages.nix` |
| GUI app on macOS | `casks` in `hosts/<system>/default.nix` |
| Homebrew formula needed because nixpkgs version is unsuitable (e.g. compile-time deps `libyaml` / `openssl@3` / `xz` for mise-built Ruby) | `brews` in `hosts/<system>/default.nix` |
| Language runtime that needs project-level pinning | `config/mise/config.toml` (nix installs `mise` itself; mise installs the toolchains) |

## Homebrew is destructive — read before you `brew install`

`modules/nix-darwin/default.nix` sets `homebrew.onActivation.cleanup = "zap"`. On the next `switch`, **anything in Homebrew that is not in this repo's `casks` or `brews` lists will be uninstalled**. Consequences:

- Never `brew install` something you intend to keep without also adding it to the corresponding host file.
- Before `brew uninstall`-ing leaves to clean up, double-check `brew uses --installed <pkg>` so you don't break a runtime dependency that nix isn't tracking (e.g. mise-managed Ruby pulls `libyaml`).

## Username differs by host

- `aarch64-darwin` → `shohei.ueda`
- `x86_64-darwin` / `x86_64-linux` → `uesho`

This is intentional. Don't normalize them.

## Validating changes

There are no tests. The validation loop is:

1. Edit `*.nix`.
2. Run the appropriate `switch` from README.
3. Flake evaluation errors surface immediately; runtime issues (e.g. a missing `brews` entry) surface on next shell or app launch.

For pure `config/` edits, just open a new shell.
