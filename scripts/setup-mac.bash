#!/usr/bin/env bash
set -x
# shellcheck source=./scripts/common.bash
source "$(dirname "$0")/common.bash"

[ "$(uname)" != "Darwin" ] && exit

#
# Global
#

# ログイン・メッセージを抑止する
touch "$HOME/.hushlogin"

# 全ての拡張子のファイルを表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ネットワークディスクに.DS_Storeを作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# USBに.DS_Storeを作成しない
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# スクリーンショットから余白を取り除く（影を消す）
defaults write com.apple.screencapture disable-shadow -bool true


#
# Finder
#

# デフォルトで隠しファイルを表示する
defaults write com.apple.finder AppleShowAllFiles -bool true
# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true
# タブバーを表示する
defaults write com.apple.finder ShowTabView -bool true
# デフォルトで表示されるフォルダをホームにする
defaults write com.apple.finder NewWindowTarget -string PfHm


#
# Dock
#

# 自動で隠す
defaults write com.apple.dock autohide -bool true
# タイトルサイズ
defaults write com.apple.dock tilesize -int 50
# 最近使ったアプリアイコンを表示しない
defaults write com.apple.dock show-recents -bool false


#
# Menubar
#

# バッテリー残量を％表記に
defaults write com.apple.menuextra.battery ShowPercent -bool true
# 日付と時刻のフォーマット（24時間表示、秒表示あり、日付・曜日を表示）
defaults write com.apple.menuextra.clock DateFormat -string "M\u6708d\u65e5(EEE)  H:mm:ss"


killall Dock
killall Finder
killall SystemUIServer
