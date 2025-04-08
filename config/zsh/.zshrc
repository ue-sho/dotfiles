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
