# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob
unsetopt notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/qxa5548/.zshrc'


autoload -Uz compinit
compinit
# End of lines added by compinstall
zstyle ':completion:*' menu select=5

#zstyle ‘:completion:*’ verbose yes
#zstyle ‘:completion:*:descriptions’ format ‘%B%d%b’
#zstyle ‘:completion:*:messages’ format ‘%d’
#zstyle ‘:completion:*:warnings’ format ‘No matches for: %d’
#zstyle ‘:completion:*’ group-name ”

source ~/.zsh/spectrum.zsh
source ~/.zsh/prompt.zsh
source ~/.zshenv
