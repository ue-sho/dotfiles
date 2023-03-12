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
    "$GOPATH/bin"(N-/)
    "$HOME/.local/share/asdf/shims"(N-/)
    "$XDG_CONFIG_HOME/scripts/bin"(N-/)
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
# カラーテーマ
zinit ice pick"async.zsh" src"pure.zsh"
zinit light sindresorhus/pure
# シンタックスハイライト
zinit light zsh-users/zsh-syntax-highlighting
# 入力補完
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
# コマンド履歴を検索
zinit light zdharma/history-search-multi-word
# git-completion
zinit wait silent lucid atclone"zstyle ':completion:*:*:git:*' script git-completion.bash" atpull"%atclone" for \
  "https://github.com/git/git/blob/master/contrib/completion/git-completion.bash"
zinit wait lucid as"completion" atload"zicompinit; zicdreplay" mv"git-completion.zsh -> _git" for \
  "https://github.com/git/git/blob/master/contrib/completion/git-completion.zsh"

### asdf-vm ###
__asdf_atload() {
    export ASDF_DATA_DIR="$XDG_DATA_HOME/asdf"
    export ASDF_CONFIG_FILE="$XDG_CONFIG_HOME/asdf/asdfrc"
}
zinit wait lucid light-mode for \
    atpull'asdf plugin update --all' \
    atload'__asdf_atload' \
    @'asdf-vm/asdf'

