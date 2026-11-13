#!/usr/bin/env zsh

if [ -n "$__HOMEBREW_PREFIX" ]; then
    eval "$("$__HOMEBREW_PREFIX/bin/brew" shellenv)"
    # brew shellenv prepends Homebrew dirs to PATH; restore mise priority.
    command -v __dotfiles_setup_path >/dev/null 2>&1 && __dotfiles_setup_path
    fpath+=("$__HOMEBREW_PREFIX/share/zsh/site-functions")
fi

if [ -n "${TMUX:-}" ]; then
    tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel pbcopy
fi

alias plcat='plutil -convert xml1 -o -'

export DOCKER_DEFAULT_PLATFORM=linux/amd64

source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# SSH uses macOS's ssh-agent; gpg-agent only signs. Load the default key into the agent once per
# login. The key has no passphrase, so nothing prompts. Never load it into gpg-agent, which wraps
# every key it is given in a pinentry passphrase.
if [[ "$(readlink -f "$SSH_AUTH_SOCK" 2>/dev/null)" != *gpg-agent* ]]; then
  ssh-add -l &>/dev/null || ssh-add -q ~/.ssh/id_ed25519 </dev/null 2>/dev/null
fi
