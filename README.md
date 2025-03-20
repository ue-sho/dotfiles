# dotfiles

このリポジトリは、Nixを使用して管理されている私の dotfiles です。

## 前提条件

### Nixのインストール

1. [Determinate Systems](https://determinate.systems/posts/determinate-nix-installer)のインストーラーを使用してNixをインストール:

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. インストール後、新しいシェルを開くか、以下のコマンドで環境を更新:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Flakesは自動的に有効化されます。

## セットアップ

1. このリポジトリをクローン:
```bash
git clone https://github.com/ue-sho/dotfiles.git
cd dotfiles
```

2. システムに応じて以下のコマンドを実行:

### macOS (Apple Silicon)
```bash
darwin-rebuild switch --flake .#aarch64-darwin
```

### macOS (Intel)
```bash
darwin-rebuild switch --flake .#x86_64-darwin
```

### Linux
```bash
nixos-rebuild switch --flake .#x86_64-linux
```

## ディレクトリ構造

```
.
├── config/          # 各アプリケーションの設定ファイル
│   ├── git/        # Gitの設定
│   ├── vim/        # Vimの設定
│   └── zsh/        # Zshの設定
│
├── hosts/          # ホスト固有の設定
│   ├── aarch64-darwin/
│   ├── x86_64-darwin/
│   └── x86_64-linux/
│
├── modules/        # Nix モジュール
│   ├── nix-darwin/ # macOS 固有の設定
│   └── home-manager/ # ユーザー環境の設定
│
└── flake.nix      # Nix Flake 設定
```

## 含まれる設定

- **システム設定** (macOS):
  - キーボードのリピート設定
  - Finder の設定
  - Dock の設定

- **パッケージ**:
  - 基本的なコマンドラインツール (git, vim, zsh)
  - システムユーティリティ (coreutils, curl, wget)

- **アプリケーション設定**:
  - Git
  - Vim
  - Zsh

## カスタマイズ

1. `config/` ディレクトリ内の各設定ファイルを編集
2. `modules/home-manager/home.nix` でパッケージや設定を追加/変更
3. `modules/nix-darwin/default.nix` でmacOSのシステム設定を変更

