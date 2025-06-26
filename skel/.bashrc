#!/bin/bash

export HISTSIZE=1000000 # 1 million lines in history, why not?
export HISTCONTROL=ignoredups

try_src() {
	for spath in "$@"
	do
		[ -a "$spath" ] && [ -r "$spath" ] && . "$spath"
	done
}

try_homesrc() {
	for spath in "$@"
	do
		try_src "$HOME/$spath"
	done
}

export DOTFILE_PATH="$HOME/.dotfiles"
# This import must be changed if DOTFILE_PATH changes.
. ~/.dotfiles/lib/common.sh

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

try_src "${__HOMEBREW_PREFIX}/etc/bash_completion"

try_src /usr/local/etc/bash_completion \
	"${__HOMEBREW_PREFIX}/etc/bash_completion"

try_homesrc .git-completion.bash || try_src \
	/etc/bash_completion.d/git \
	/usr/local/etc/bash_completion.d/git \

[ -x "$(command -v __git_complete)" ] && __git_complete g __git_main

add_os_rc "bash"

try_homesrc ".bash-git-prompt/gitprompt.sh"

try_homesrc .bashrc.local

export GPG_TTY=$(tty)
