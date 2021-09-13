#!/bin/bash

export HISTSIZE=1000000 # 1 million lines in history, why not?
export HISTCONTROL=ignoredups

# This import must be changed if DOTFILE_PATH changes.
. ~/.dotfiles/lib/common.sh

dotfile "lib/helpers-tmux.sh"

function prompt_callback() {
	local EXTRAS
	EXTRAS=" / » "
	local GITDIR
	GITDIR="$(git rev-parse --show-toplevel 2>/dev/null)"
	if [[ -e "$GITDIR" ]]; then
		GIT_DESCRIBE_OUTPUT=$(git describe --tags --always 2>/dev/null)
		export GIT_REPO_SUMMARY="[$GITDIR:$GIT_DESCRIBE_OUTPUT]"
		EXTRAS="${EXTRAS} [\\[\\033[0;36m\\]${GIT_DESCRIBE_OUTPUT}\\[\\033[0;37m\\]]"
	fi
	if [ -n "$EXTRAS" ]; then echo "$EXTRAS"; fi
}

if [ -f /usr/local/etc/bash_completion ]; then
	# tell shellcheck to stop complaining about conditional includes
	# shellcheck disable=1091
	. /usr/local/etc/bash_completion
fi

if [ -f ~/.git-completion.bash ]; then
	. ~/.git-completion.bash
elif [ -f /usr/local/etc/bash_completion.d/git ]; then
	# tell shellcheck to stop complaining about conditional includes
	# shellcheck disable=1091
	. /usr/local/etc/bash_completion.d/git
elif [ -f /etc/bash_completion.d/git ]; then
	# shellcheck disable=1091
	. /etc/bash_completion.d/git
fi

[ -x "$(command -v __git_complete)" ] && __git_complete g __git_main

#!/bin/bash

__HOMEBREW_PREFIX=$(brew --prefix 2>/dev/null)
if [ -f "$__HOMEBREW_PREFIX/opt/bash-git-prompt/share/gitprompt.sh" ]; then
	__GIT_PROMPT_DIR="$__HOMEBREW_PREFIX/opt/bash-git-prompt/share"
	export GIT_PROMPT_THEME="Custom"
	# GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh
	export GIT_PROMPT_SHOW_UNTRACKED_FILES=no
	export GIT_PROMPT_FETCH_REMOTE_STATUS=0
	source "$__GIT_PROMPT_DIR/gitprompt.sh"
else
	echo "Git prompt not found. Run brew install bash-git-prompt"
fi
if [[ -f ${__HOMEBREW_PREFIX}/etc/bash_completion ]]; then
	. "${__HOMEBREW_PREFIX}/etc/bash_completion"
fi

__lpass_complete_name() {
	local cur="$2"
	local matches

	# matches on full path
	matches=$(lpass ls --sync=no | grep -E "^$cur" | awk '{print $1}')
	# matches on leaves
	matches+=$(lpass ls --sync=no | grep -E "/$cur" | sed -e "s/ \\[id.*//g" |
		awk -F '/' '{print $NF}')

	while IFS=$'\n' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$matches" "$cur")
}

complete -o default -F __lpass_complete_name p
complete -o default -F __lpass_complete_name u
complete -o default -F __lpass_complete_name 'lpass show'

add_os_rc "$(uname)" "bash"

[ ! -f ~/.bashrc.local ] || . ~/.bashrc.local
