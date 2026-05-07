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
