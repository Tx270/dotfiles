if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
KEYTIMEOUT=1

zstyle ':omz:update' mode reminder
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

export EDITOR='nvim'
export VISUAL='nvim'

alias v='nvim'
alias c='printf "\033c"'
alias e='echo'
alias q='exit'
alias ls='colorls'
alias tp='trash-put'
alias cat='bat'
alias catx='copyfile'
alias pwdx='copypath'
alias icat='kitten icat'
alias fzf='fzf --style=full'

alias rm='echo "This is not the command you are looking for."; false'
alias cd='echo "This is not the command you are looking for."; false'
alias refresh='source ~/.zshrc && echo "Refreshed terminal source"'
alias update='sudo dnf update && sudo dnf upgrade'
alias folder-to-cbz='/bin/ls -1v -- *.png 2>/dev/null | tr '\n' '\0' | xargs -0 zip -j ../comic.cbz'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	/bin/rm -f -- "$tmp"
}

function vault() {
  case "$1" in
    mount)
      gocryptfs -noprealloc ~/.vlt ~/Other/Vault
      ;;
    umount)
      fusermount3 -u ~/Other/Vault
      ;;
    *)
      echo "Usage: vault {mount|umount}"
      return 1
      ;;
  esac
}

function nas() {
  case "$1" in
    mount)
      sshfs -o IdentityFile=~/.ssh/id_ed25519 -o port=77 -o reconnect -o ServerAliveInterval=15 Tomek@100.95.249.27:Storage ~/Other/Nas
      ;;
    umount)
      fusermount -u ~/Other/Nas
      ;;
    *)
      echo "Usage: nas {mount|umount}"
      return 1
      ;;
  esac
}



alias lta='$HOME/.local/scripts/lta.sh'

source <(fzf --zsh)
bindkey -r '^T'
bindkey '^F' fzf-file-widget
export FZF_DEFAULT_OPTS_FILE=~/.config/fzf/fzf.conf

eval "$(zoxide init zsh)"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(atuin init zsh --disable-up-arrow)"

export PATH=$PATH:$HOME/.local/share/gem/ruby/gems/colorls-1.5.0/exe
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
