[ ! -f $HOME/.zshrc.localbefore ] || . $HOME/.zshrc.localbefore

export ZDOTDIR="$HOME"

. "$HOME/.dotfiles/lib/runtimes.sh"

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
}

__my-zsh-keybindings

function __my-zsh-completions {
  autoload -Uz compinit
	zsh-plugin-load zetlen/zsh-completion-generators
	zsh-plugin-load zsh-users/zsh-completions
	compinit
	zsh-plugin-load Aloxaf/fzf-tab
  # disable sort when completing `git checkout`
  zstyle ':completion:*:git-checkout:*' sort false
  # set descriptions format to enable group support
  zstyle ':completion:*:descriptions' format '[%d]'
  # set list-colors to enable filename colorizing
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  # preview directory's content with eza when completing cd
  i_have eza && zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1F --icons --color-scale --color=always $realpath'
  # switch group using `,` and `.`
  zstyle ':fzf-tab:*' switch-group ',' '.'
}

__my-zsh-completions

function __my-zsh-prompt {
  eval "$(starship init zsh)"
}

[ -z "$SIMPLE_PROMPT" ] && __my-zsh-prompt

function __my-zsh-plugins {
	zsh-plugin-load zetlen/zsh-bitwarden
}

__my-zsh-plugins

function __my-zsh-history {
    local FOUND_ATUIN=$+commands[atuin]

    if [[ $FOUND_ATUIN -eq 1 ]]; then
      source <(atuin init zsh --disable-up-arrow)
    fi
}

__my-zsh-history

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

test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh"


# Added by Antigravity
export PATH="/Users/zetlen/.antigravity/antigravity/bin:$PATH"
