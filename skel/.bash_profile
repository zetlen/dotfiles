#!/bin/bash

__dotfiles_profile="$HOME/.profile"
[ -r "$__dotfiles_profile" ] || __dotfiles_profile="$HOME/.dotfiles/skel/.profile"
[ -r "$__dotfiles_profile" ] && . "$__dotfiles_profile"

case $- in
*i*) [ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc" ;;
esac

unset __dotfiles_profile
