export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.local/scripts"
export HISTFILE="${XDG_STATE_HOME}/zsh_history"
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"

if [[ -r "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"

CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
KEYTIMEOUT=1

zstyle ':omz:update' mode auto
plugins=(
	git
	copyfile
	copypath
	sudo
	dirhistory
	zsh-allclear
	zsh-autosuggestions
	zsh-syntax-highlighting
  zsh-vim-mode
)

source $ZSH/oh-my-zsh.sh

alias cd='z'
alias v='nvim'
alias c='printf "\033c"'
alias e='echo'
alias q='exit'
alias ls='lsd'
alias cat='bat'
alias tp='trash-put'
alias catx='copyfile'
alias pwdx='copypath'
alias icat='kitten icat'
alias k='setsid kitty >/dev/null 2>&1 < /dev/null &'
alias fzf='fzf --style=full'

alias rm='echo "This is not the command you are looking for."; false'
alias refresh='source ~/.config/zsh/.zshrc && echo "Refreshed terminal source"'
alias update='sudo dnf update && sudo dnf upgrade'
alias phps='php -S 127.0.0.1:8080'


function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	/bin/rm -f -- "$tmp"
}

function make_cbz() {
    local name
    name="$(basename "$PWD").cbz"

    find . -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" \) -printf "%f\n" \
    | sort -V \
    | zip "../$name" -@
}

bindkey -r '^T'
bindkey '^F' fzf-file-widget
export FZF_DEFAULT_OPTS_FILE=~/.config/fzf/fzf.conf
source <(fzf --zsh)

compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

eval "$(zoxide init zsh)"

[[ -f "$HOME/.config/zsh/p10k.zsh" ]] && source "$HOME/.config/zsh/p10k.zsh"
eval "$(atuin init zsh --disable-up-arrow)"
