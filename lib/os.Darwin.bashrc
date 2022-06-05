#!/bin/bash

__HOMEBREW_PREFIX=$(brew --prefix 2>/dev/null)
if [ -f "$__HOMEBREW_PREFIX/opt/bash-git-prompt/share/gitprompt.sh" ]; then
	__GIT_PROMPT_DIR="$__HOMEBREW_PREFIX/opt/bash-git-prompt/share"
	export GIT_PROMPT_THEME="Custom"
	# GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh
	export GIT_PROMPT_SHOW_UNTRACKED_FILES=no
	export GIT_PROMPT_FETCH_REMOTE_STATUS=0
	source "$__GIT_PROMPT_DIR/gitprompt.sh"
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && . "${HOME}/.iterm2_shell_integration.bash"
