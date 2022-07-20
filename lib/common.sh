#!/bin/sh
# shellcheck disable=SC1090,SC1091
# tell shellcheck to quit complaining about dynamic paths

export SVN_EDITOR="vim"
export EDITOR="vim"

export COLONPIPE="zetlen@colonpipe.org:~/colonpipe.org/"
export JAVA_HOME
if [ -x "/usr/libexec/java_home" ]; then
	JAVA_HOME="$(/usr/libexec/java_home)"
fi

sesh() {
	local name
	name="$(hostname -s)"
	printf '\e]1;%s\a' "$name"
	autossh -t -M 0 $1 "tmux attach -d -t $name || tmux new -s $name"
}

alias la='ls -lahAFG'
alias l='ls -lahp'
alias ls='ls -p'
if command -v exa >/dev/null; then
	alias l='exa -lahF --color-scale --git'
	alias la='l --sort=accessed'
	alias lt='l --sort=modified'
fi
alias cd..='cd ..'
alias r="rsync -avhzPC" # skip .git and other common skips
alias rr="rsync -avhzP" # don't skip that
alias g=git
alias p="lpass show -c --password"
alias u="lpass show -c --username"
alias unixify="find . -type f -print0 | xargs -0 -n 1 -P 4 dos2unix"
alias exifkill="exiftool -all= "
alias wvim='vim -u ~/.vimrc_txt'

mdcd() {
	mkdir -p "$*" && cd "$*" || return
}

sizes() {
	local dir="${1:-.}"
	local depth="${2:-1}"
	du -chad "$depth" "$dir" | sort -h
}

# POSIX-compatible contains(string, substring)
#
# Returns 0 if the specified string contains the specified substring,
# otherwise returns 1.
contains() {
	string="$1"
	substring="$2"
	if test "${string#*$substring}" != "$string"; then
		return 0 # $substring is in $string
	else
		return 1 # $substring is not in $string
	fi
}

free_port() {
	local pids="$(lsof -t -i tcp:"$1" | xargs)"
	if [ -z "$pids" ]; then
		echo "Found no processes bound to port $1"
	else
		echo "Processes bound to port $1:"
		echo "$pids" | tr ' ' ',' | xargs ps -o pid,command -p
		echo "Kill them [y/N]?"
		read -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			kill -9 $pids
		fi
	fi
}


DOTFILE_PATH="$HOME/.dotfiles/"

# POSIX-compatible sourcing
dotfile() {
	# shellcheck disable=SC1090
	. "$DOTFILE_PATH/$1"
}

get_os_id() {
	if [ -e /etc/os-release ]; then
		. /etc/os-release
		echo $ID
	else
		uname | tr '[:upper:]' '[:lower:]'
	fi
}

add_os_rc() {
	THE_OS="$(get_os_id)"
	THE_SHELL="$2"
	# fail silently if it doesn't exist
	dotfile "lib/os.${THE_OS}.sh" 2>/dev/null || true
	dotfile "lib/os.${THE_OS}.${THE_SHELL}rc" 2>/dev/null || true
}

for file in "$DOTFILE_PATH"/lib/helpers-*.sh; do
	. "$file"
done

export PATH="/usr/local/heroku/bin:$HOME/bin:/usr/local/share/npm/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.cargo/bin:$HOME/.yarn/bin:$PATH:$HOME/.composer/vendor/bin:$HOME/.rvm/bin:$HOME/Library/Python/3.9/bin"

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -s "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"

