# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# This import must be changed if DOTFILE_PATH changes.
. ~/.dotfiles/lib/common.sh

OSNAME="$(uname)"

add_os_rc "$OSNAME" "zsh"
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

ZSH_THEME="powerlevel10k/powerlevel10k"
# User configuration

# tweaks
setopt +o nomatch

# good history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=10000
setopt histignoredups
setopt histignorespace
setopt histreduceblanks
setopt histfcntllock
setopt histexpiredupsfirst
setopt appendhistory

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# vim keybindings
bindkey -v
# get rid of keytimeout for command mode
export KEYTIMEOUT=1

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

bindkey "^?" backward-delete-char
bindkey "${terminfo[kend]}" end-of-line
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kdch1]}" delete-char
bindkey "${terminfo[kbs]}" backward-delete-char
bindkey "${terminfo[kpp]}" beginning-of-buffer-or-history
bindkey "${terminfo[knp]}" end-of-buffer-or-history
bindkey "${terminfo[kcbt]}" reverse-menu-complete

bindkey -M viins "${terminfo[kend]}" end-of-line
bindkey -M viins "${terminfo[khome]}" beginning-of-line
bindkey -M viins "${terminfo[kdch1]}" delete-char
bindkey -M viins "${terminfo[kbs]}" backward-delete-char
bindkey -M viins "${terminfo[kpp]}" beginning-of-buffer-or-history
bindkey -M viins "${terminfo[knp]}" end-of-buffer-or-history
bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
bindkey -M viins "${terminfo[kich1]}" vi-cmd-mode

bindkey -M vicmd "${terminfo[kich1]}" vi-insert
bindkey -M vicmd "${terminfo[kdch1]}" vi-delete-char
bindkey -M vicmd "${terminfo[kend]}" end-of-line
bindkey -M vicmd "${terminfo[khome]}" beginning-of-line
bindkey -M vicmd "${terminfo[kbs]}" vi-backward-char
bindkey -M vicmd "${terminfo[kpp]}" beginning-of-buffer-or-history
bindkey -M vicmd "${terminfo[knp]}" end-of-buffer-or-history
bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

fpath=($HOME/.asdf/completions $fpath)

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
# autoload -Uz _zinit
# (( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for zdharma-continuum/zinit-annex-as-monitor zdharma-continuum/zinit-annex-bin-gem-node zdharma-continuum/zinit-annex-patch-dl zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

### Beginning of Zinit's configuration chunk

zinit light romkatv/powerlevel10k

zinit wait lucid for \
	mafredri/zsh-async \
	jeffreytse/zsh-vi-mode \
	chrisands/zsh-yarn-completions \
	redxtech/zsh-asdf-direnv

zinit wait lucid for \
   atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
       zdharma-continuum/fast-syntax-highlighting

# End of Zinit's configuration chunk

# To customize prompt, run `p10k configure` or edit ~/.dotfiles/.p10k.zsh.
[[ ! -f ~/.dotfiles/.p10k.zsh ]] || source ~/.dotfiles/.p10k.zsh

# must happen after initialization of p10k and other async things
GPG_TTY=$TTY

[ ! -f ~/.zshrc.local ] || . ~/.zshrc.local
