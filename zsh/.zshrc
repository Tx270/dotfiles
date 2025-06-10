if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

# https://github.com/ohmyzsh/ohmyzsh/wiki/Themes or random
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
alias x='exit'
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
alias rbot='ssh -t -i ~/.ssh/id_ed25519 -p 77 Tomek@192.168.1.100 "/usr/local/bin/docker restart discord-bot" && notify-send "Powiadomienie" "Discord bot reset complete!"'


# ENABLE_CORRECTION="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"


[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
eval "$(atuin init zsh --disable-up-arrow)"
#. "$HOME/.atuin/bin/env"

export PATH=$PATH:$HOME/.local/share/gem/ruby/gems/colorls-1.5.0/exe
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.local/bin
