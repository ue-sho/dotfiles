# uesho's dotfiles

Nixを使用してdotfilesを管理するリポジトリです。nix-darwinとhome-managerを使用して、macOSとLinux環境の設定を行います。

## ディレクトリ構造

```
root
|-- config         # 実際の設定ファイル
│   ├── zsh        # Zsh設定
│   ├── git        # Git設定
│   ├── vim        # Vim設定
|
|── hosts          # ホスト固有の設定
│   ├── aarch64-darwin  # Apple Silicon Mac用設定
│   ├── x86_64-darwin   # Intel Mac用設定
│   ├── x86_64-linux    # Linux用設定
|
|── modules        # 共通モジュール
│   ├── nix-darwin       # nix-darwin用共通設定
│   ├── home-manager     # home-manager用共通設定
|
|--flake.nix       # Nix Flake設定
```

## セットアップ方法

### 前提条件

- Nixがインストールされていること
- Flakesが有効になっていること

### インストール

#### macOS (nix-darwin + home-manager)

**Apple Silicon Mac:**

```bash
# 初回インストール
nix run --experimental-features 'nix-command flakes' github:LnL7/nix-darwin -- \
  switch --flake .#arm-mac

# 更新
darwin-rebuild switch --flake .#arm-mac
```

**Intel Mac:**

```bash
# 初回インストール
nix run --experimental-features 'nix-command flakes' github:LnL7/nix-darwin -- \
  switch --flake .#intel-mac

# 更新
darwin-rebuild switch --flake .#intel-mac
```

#### Linux または スタンドアロンhome-manager (macOS)

**Linux:**

```bash
# 初回インストール
nix run --experimental-features 'nix-command flakes' home-manager/master -- \
  switch --flake .#uesho@ubuntu

# 更新
home-manager switch --flake .#uesho@ubuntu
```

**macOS (home-managerのみ):**

```bash
# Apple Silicon Mac
home-manager switch --flake .#uesho@arm-mac

# Intel Mac
home-manager switch --flake .#uesho@intel-mac
```

## 更新方法

設定を変更した後は、以下のコマンドで適用します：

```bash
# nix-darwin (macOS)
darwin-rebuild switch --flake .

# home-manager (Linux or スタンドアロン)
home-manager switch --flake .
```

## カスタマイズ

1. `config/` ディレクトリに実際の設定ファイルを配置
2. `hosts/` 内の対応するホスト設定を編集
3. 共通設定は `modules/` 内のファイルを編集

## 注意点

- 設定ファイルは `config/` ディレクトリに置かれ、シンボリックリンクされます
- ホスト固有の設定は各ホストディレクトリで行います
- 共通モジュールは複数のホストで再利用されます

