if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    __GIT_PROMPT_DIR="$HOME/.bash-git-prompt" 
    GIT_PROMPT_THEME="Custom"
    # GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh
    GIT_PROMPT_SHOW_UNTRACKED_FILES=no
    GIT_PROMPT_FETCH_REMOTE_STATUS=0
    source "$__GIT_PROMPT_DIR/gitprompt.sh"
else
  echo "Git prompt not found. Clone bash-git-prompt repository to .bash-git-prompt"
fi


tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'