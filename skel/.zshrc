[ ! -f $HOME/.zshrc.localbefore ] || . $HOME/.zshrc.localbefore

export ZDOTDIR="$HOME"

# This import must be changed if DOTFILE_PATH changes.
. ~/.dotfiles/lib/common.sh

add_os_rc "zsh"

# OPTIONS

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
	function zvm_config() {
		ZVM_INIT_MODE=sourcing
		ZVM_LAZY_KEYBINDINGS=false
	}
	zsh-plugin-load jeffreytse/zsh-vi-mode
	zvm_define_widget p10k_toggle_versions _p10k_toggle_versions
	zvm_bindkey vicmd '^E' p10k_toggle_versions
	zvm_bindkey viins '^E' p10k_toggle_versions
}

__my-zsh-keybindings

function __my-zsh-completions {
  autoload -Uz compinit
	zsh-plugin-load zetlen/zsh-completion-generators
	zsh-plugin-load zsh-users/zsh-completions
	compinit
	zsh-plugin-load lukechilds/zsh-better-npm-completion
	zsh-plugin-load chrisands/zsh-yarn-completions
	zsh-plugin-load Aloxaf/fzf-tab
  # disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # set descriptions format to enable group support
  zstyle ':completion:*:descriptions' format '[%d]'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # preview directory's content with exa when completing cd
  i_have exa && zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1F --color-scale $realpath'
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
	zsh-plugin-load olets/zsh-window-title
	zsh-plugin-load ptavares/zsh-direnv
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

# set asdf-golang variables
export ASDF_GOLANG_MOD_VERSION_ENABLED=true

[ ! -f ~/.zshrc.local ] || . ~/.zshrc.local
