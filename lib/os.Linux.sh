#!/bin/sh

if [ "$IN_TMUX" -eq "1" ]; then
  tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
fi
