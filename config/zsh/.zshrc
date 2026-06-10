### zinit ###
typeset -gAH ZINIT
ZINIT[HOME_DIR]="$XDG_DATA_HOME/zinit"
ZINIT[ZCOMPDUMP_PATH]="$XDG_STATE_HOME/zcompdump"
source "${ZINIT[HOME_DIR]}/bin/zinit.zsh"

### paths ###
typeset -U path
typeset -U fpath

path=(
    "$HOME/.local/bin"(N-/)
    "$HOME/.volta/bin"
    "$GOPATH/bin"(N-/)
    "$XDG_CONFIG_HOME/scripts/bin"(N-/)
    "$HOME/.rd/bin"(N-/)  # rancher desktop
    "$path[@]"
)

fpath=(
    "$XDG_DATA_HOME/zsh/completions"(N-/)
    "$fpath[@]"
)

### plugins ###
zinit wait lucid null for \
    atinit'source "$ZDOTDIR/.zshrc.lazy"' \
    @'zdharma-continuum/null'
# color theme
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure
# kube-ps1: show kube context/namespace in RPROMPT
# kube_ps1 は内部で kubectl を起動するため、到達不能なクラスタ(例: 自宅の
# raspberrypi)が current-context だと kubectl がタイムアウト待ちで数秒固まる。
# 遅延ロード(wait)でも初回コマンド入力時にその待ちが走ってしまうので、
# プラグインは一切自動ロードせず、`kubeon` を呼んだときだけロードする。
# (`kubeoff` で RPROMPT を消す。プラグインはロードされたまま残る。)
KUBE_PS1_SYMBOL_ENABLE=false
kubeon() {
  zinit light jonmosco/kube-ps1
  RPROMPT='$(kube_ps1)'
}
kubeoff() { RPROMPT=''; }
# syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting
# input completion
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
# search command history
zinit light zdharma/history-search-multi-word
# git-completion
zinit wait silent lucid atclone"zstyle ':completion:*:*:git:*' script git-completion.bash" atpull"%atclone" for \
  "https://github.com/git/git/blob/master/contrib/completion/git-completion.bash"
zinit wait lucid as"completion" atload"zicompinit; zicdreplay" mv"git-completion.zsh -> _git" for \
  "https://github.com/git/git/blob/master/contrib/completion/git-completion.zsh"

# pnpm
export PNPM_HOME="/Users/shohei.ueda/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
