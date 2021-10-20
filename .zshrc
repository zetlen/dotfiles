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

# good history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=10000
setopt histignoredups
setopt histignorespace
setopt histreduceblanks
setopt histfcntllock
setopt histexpiredupsfirst

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

[ ! -f ~/.zshrc.local ] || . ~/.zshrc.local

# vim keybindings
bindkey -v
# get rid of keytimeout for command mode
export KEYTIMEOUT=1

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

# configure fast-zsh-nvm plugin
AUTO_LOAD_NVMRC_FILES=true

install_antibody_plugins() {
  for plugin in "$@"
  do
    echo $plugin >> $(realpath ~/.zsh_plugins.txt)
  done
  antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh && . ~/.zsh_plugins.sh
}

if command -v antibody > /dev/null; then
  [ -e "${HOME}/.zsh_plugins.sh" ] && . ~/.zsh_plugins.sh || install_antibody_plugins
fi

# set default node in lieu of having a default node in the system
command -v node > /dev/null || nvm use default 2>/dev/null

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# BEGIN SNIPPET: Magento Cloud CLI configuration
HOME=${HOME:-'/Users/jzetlen'}
export PATH="$HOME/"'.magento-cloud/bin':"$PATH"
if [ -f "$HOME/"'.magento-cloud/shell-config.rc' ]; then . "$HOME/"'.magento-cloud/shell-config.rc'; fi # END SNIPPET

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# To customize prompt, run `p10k configure` or edit ~/.dotfiles/.p10k.zsh.
[[ ! -f ~/.dotfiles/.p10k.zsh ]] || source ~/.dotfiles/.p10k.zsh
