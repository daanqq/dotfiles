# variables
export PATH="$HOME/.local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump"

# binds
bindkey '^H' backward-kill-word # for windows terminal

# plugins
plugins=(git sudo zsh-autosuggestions)

# sources
source $ZSH/oh-my-zsh.sh

# evals
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# aliases
alias g="git"
alias s="sudo"
alias c="clear"
alias l="eza -la --icons --group-directories-first"
alias ls="eza --icons --group-directories-first"
alias rmf="rm -rf"
alias cat="batcat"
alias top="btop"
alias htop="btop"
alias fetch="fastfetch"
mkcd() {
  mkdir $1 && cd $1
}

# (fnm)
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env`"
fi

# (fzf)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# utilities
alias backup_win_term="cp /mnt/c/Users/Danila/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json ~/.dotfiles/windows/settings.json"
