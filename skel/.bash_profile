#!/bin/bash

__dotfiles_profile="$HOME/.profile"
[ -r "$__dotfiles_profile" ] || __dotfiles_profile="$HOME/.dotfiles/skel/.profile"
[ -r "$__dotfiles_profile" ] && . "$__dotfiles_profile"

__dotfiles_bash_env="${BASH_ENV:-$HOME/.bash_env}"
[ -r "$__dotfiles_bash_env" ] || __dotfiles_bash_env="$HOME/.dotfiles/skel/.bash_env"
[ -r "$__dotfiles_bash_env" ] && . "$__dotfiles_bash_env"

case $- in
*i*) [ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc" ;;
esac

unset __dotfiles_profile __dotfiles_bash_env
