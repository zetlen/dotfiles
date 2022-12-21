#!/usr/bin/env zsh

if type brew &>/dev/null; then
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
