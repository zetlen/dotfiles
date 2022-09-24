export LANG=en_US.UTF-8

# This import must be changed if DOTFILE_PATH changes.
. ~/.dotfiles/lib/common.sh

# raw dog plugin manager
dotfile lib/zsh-plugins.zsh
zsh-plugin-init

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

add_os_rc "zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

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

export MANPATH="/usr/local/man:$MANPATH"

function __my-zsh-keybindings {
	zsh-plugin-load jeffreytse/zsh-vi-mode

	# Enable Ctrl-x-e to edit command line
	autoload -U edit-command-line
	zle -N edit-command-line
	bindkey '^X^E' edit-command-line
}

__my-zsh-keybindings

function __my-zsh-completions {
	fpath=($HOME/.asdf/completions $fpath)
	eval "$(bw completion --shell zsh); compdef _bw bw;"
}

__my-zsh-completions

function __my-zsh-prompt {
	zsh-plugin-load romkatv/powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.dotfiles/.p10k.zsh.
. "${HOME}/.p10k.zsh"
}

__my-zsh-prompt

function __my-zsh-plugins {
	zsh-plugin-load zetlen/zsh-bitwarden
	zsh-plugin-load redxtech/zsh-asdf-direnv
}

__my-zsh-plugins

# must happen after initialization of p10k and other async things
export GPG_TTY=$TTY

# Fix for passphrase prompt on the correct tty
# See https://www.gnupg.org/documentation/manuals/gnupg/Agent-Options.html#option-_002d_002denable_002dssh_002dsupport
function _gpg-agent_update-tty_preexec {
  gpg-connect-agent updatestartuptty /bye &>/dev/null
}
autoload -U add-zsh-hook
add-zsh-hook preexec _gpg-agent_update-tty_preexec

# If enable-ssh-support is set, fix ssh agent integration
if [[ $(gpgconf --list-options gpg-agent 2>/dev/null | awk -F: '$1=="enable-ssh-support" {print $10}') = 1 ]]; then
  unset SSH_AGENT_PID
  if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]]; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
fi

[ ! -f ~/.zshrc.local ] || . ~/.zshrc.local
