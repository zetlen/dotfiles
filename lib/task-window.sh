#!/bin/bash
if ! tmux select-window -t TASKS 2>/dev/null; then
  tmux new-window -c ~ -n TASKS 'bash --init-file <(echo ". \"$HOME/.bash_profile\"; tmux rename-window TASKS; tmux swap-window -t :1; task")'
fi
