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

export PATH="/usr/local/heroku/bin:$HOME/bin:/usr/local/share/npm/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.cargo/bin:$HOME/.yarn/bin:$PATH:$HOME/.composer/vendor/bin:$HOME/.rvm/bin:$HOME/Library/Python/3.9/bin"

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -s "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"

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

normalize_dir() {
	# Join all arguments by /
	local IFS=$'/'
	local the__path="$*"
	
	# Remove all multiple slashes ///
	the__path=$(echo "$the__path" | tr -s /)

	# Remove all /./ sequences.
	the__path=${the__path//\/.\//\/}

	# Remove any final trailing slash.
	echo "${the__path%/}"
}

DOTFILE_PATH="$(normalize_dir $HOME .dotfiles)"

# POSIX-compatible sourcing
dotfile() {
	# shellcheck disable=SC1090
	. "$(normalize_dir $DOTFILE_PATH $1)"
}

get_os_id() {
	KERNEL_ID="$(uname | tr '[:upper:]' '[:lower:]')";
	if [[ "$KERNEL_ID" == "linux" && -e /etc/os-release ]]; then
		. /etc/os-release
		echo "$KERNEL_ID/$ID"
	else
		echo "$KERNEL_ID"
	fi
}

get_os_dotfile_path() {
	local osid="$(get_os_id)"
	local ospaths="$(normalize_dir $DOTFILE_PATH os)"
	local osidpath="$(normalize_dir $ospaths $osid)"
	if [ ! -d "$osidpath" ]; then
		osidpath="$(dirname $osidpath)"
		osidpath="$(normalize_dir $osidpath generic)"
	fi
	if [ ! -d "$osidpath" ]; then
		osidpath="$(normalize_dir $ospaths generic)"
	fi
	echo $osidpath
}

add_os_rc() {
	THE_SHELL="$2"
	# fail silently if it doesn't exist
	. "$(get_os_dotfile_path)/.${THE_SHELL}rc" 2>/dev/null || true
}

for file in "$DOTFILE_PATH"/lib/helpers-*.sh; do
	. "$file"
done
