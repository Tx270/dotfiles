if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="true"

zstyle ':omz:update' mode reminder
plugins=(
	git
	z
	wd
	copyfile
	copypath
	sudo
	dirhistory
	web-search
	zsh-allclear
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'
export VISUAL='nvim'

alias v='nvim'
alias c='printf "\033c"'
alias e='echo'
alias q='exit'
alias y='yazi'
alias ls='colorls'
alias tp='trash-put'
alias cat='bat'
alias catx='copyfile'
alias pwdx='copypath'
alias icat='kitten icat'

alias rm='echo "This is not the command you are looking for."; false'
alias refresh='source ~/.zshrc && echo "Refreshed terminal source"'
alias update='sudo dnf update && sudo dnf upgrade'

alias nas='$HOME/.local/scripts/nas/main.sh'
alias lta='$HOME/.local/scripts/lta.sh'

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(atuin init zsh --disable-up-arrow)"

export PATH=$PATH:$HOME/.local/share/gem/ruby/gems/colorls-1.5.0/exe
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
