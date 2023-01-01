[ ! -f $HOME/.zshrc.localbefore ] || . $HOME/.zshrc.localbefore
export LANG="en_US.UTF-8"
export LANGUAGE="$LANG"
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"

export ZDOTDIR="$HOME"

# This import must be changed if DOTFILE_PATH changes.
. ~/.dotfiles/lib/common.sh

add_os_rc "zsh"

# raw dog plugin manager
. "$DOTFILE_PATH/lib/zsh-plugins.zsh"
zsh-plugin-init

# good history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt histignoredups
setopt histignorespace
setopt histreduceblanks
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
  autoload -Uz compinit
	if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
		compinit;
	else
		compinit -C;
	fi;
	zsh-plugin-load Aloxaf/fzf-tab
  # disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # set descriptions format to enable group support
  zstyle ':completion:*:descriptions' format '[%d]'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # preview directory's content with exa when completing cd
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1aF --color-scale'
  # switch group using `,` and `.`
  zstyle ':fzf-tab:*' switch-group ',' '.'
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

# fix ssh agent integration
unset SSH_AGENT_PID
if [[ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]]; then
	export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

[ ! -f ~/.zshrc.local ] || . ~/.zshrc.local
