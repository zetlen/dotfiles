#!/bin/bash

. "$HOME/.dotfiles/lib/logging.sh"

flog_success "Void Linux detected. Using XBPS package manager."

flog_confirm "Run xbps-install -Su (twice)?" && sudo xbps-install -Su && sudo xbps-install -Su 

flog_confirm "Run xbps-install zsh curl wget git vim ripgrep fzf gnupg2 bat?" && sudo xbps-install zsh git curl wget vim ripgrep fzf gnupg2 bat
