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

export GPG_TTY=$(tty)

#### friendly logging ####
# color codes, blank until we know colors are supported
__flog_color_standout=""
__flog_color_normal=""
__flog_color_red=""
__flog_color_green=""
__flog_color_yellow=""

__flog_sym_good=""

__flog_tab_len=0
__flog_tab=""

flog_indent() {
	level="$1"
	__flog_tab_len="$((__flog_tab_len + level))"
	__flog_tab=$(printf "%-${__flog_tab_len}s")
}

# fallback style
function flog_log() {
	echo -e "[INFO]: ${__flog_tab}$*"
}
function flog_warn() {
	echo -e "[WARNING]: ${__flog_tab}$*" >&2
}
function flog_error() {
	echo -e "[ERROR]: ${__flog_tab}$*" >&2
}
function flog_success() {
	echo -e "[SUCCESS]: ${__flog_tab}$*"
}

# but if stdout is a terminal...
if [ -t 1 ]; then

	# see if it supports colors...
	ncolors=$(tput colors)

	__flog_fancy=1

	if [ -n "$ncolors" ] && [ "$ncolors" -ge 4 ]; then
		__flog_color_standout="$(tput smso)"
		__flog_color_normal="$(tput sgr0)"
		__flog_color_red="$(tput setaf 1)"
		__flog_color_green="$(tput setaf 2)"
		__flog_color_yellow="$(tput setaf 3)"

    __flog_sym_success=$'\xE2\x9C\x94\xEF\xB8\x8E'
		__flog_sym_warn=$'\xE2\x9A\xA0'
		__flog_sym_error=$'\xE2\x9C\x96\xEF\xB8\x8E'

		# and make the logging functions human-friendly
		function flog_log() {
			echo -e "${__flog_tab}${*}${__flog_color_normal}"
		}

		function __flog_loglevel() {
			local sym
			local prefix
			sym="$1${__flog_color_standout} $2 ${__flog_color_normal}$1"
			shift
			shift
			flog_log "$sym $*"
		}
		function flog_warn() {
			__flog_loglevel "$__flog_color_yellow" "$__flog_sym_warn" "$*"
		}
		function flog_error() {
			__flog_loglevel "$__flog_color_red" "$__flog_sym_error" "$*"
		}
    function flog_success() {
			__flog_loglevel "$__flog_color_green" "$__flog_sym_success" "$*"
    }

	fi
fi

function sesh() {
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
alias mc="magento-cloud"
mdcd() {
	mkdir -p "$*" && cd "$*" || return
}

export PATH="/usr/local/heroku/bin:$HOME/bin:/usr/local/share/npm/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.cargo/bin:$HOME/.yarn/bin:$PATH:$HOME/.composer/vendor/bin:$HOME/.rvm/bin:$HOME/Library/Python/3.9/bin"

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

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

DOTFILE_PATH="$HOME/.dotfiles/"

# POSIX-compatible sourcing
dotfile() {
	# shellcheck disable=SC1090
	. "$DOTFILE_PATH/$1"
}

add_os_rc() {
	THE_OS="$1"
	THE_SHELL="$2"
	# fail silently if it doesn't exist
	dotfile "lib/os.${THE_OS}.sh" 2>/dev/null || true
	dotfile "lib/os.${THE_OS}.${THE_SHELL}rc" 2>/dev/null || true
}

dotfile "lib/helpers-node.sh"
dotfile "lib/helpers-tmux.sh"
dotfile "lib/helpers-local.sh"
