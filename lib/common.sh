#!/bin/sh
# shellcheck disable=SC1090,SC1091
# tell shellcheck to quit complaining about dynamic paths

export LANG=en_US.UTF-8
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"

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
      echo "$pids" | tr ' ' '\n' | xargs kill -9
    fi
  fi
}

# not necessary 90% of the time
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

DOTFILE_PATH="$HOME/.dotfiles"

# POSIX-compatible sourcing
dotfile() {
  # shellcheck disable=SC1090
  . "$($DOTFILE_PATH $1)"
}

get_os_id() {
  KERNEL_ID="$(uname)"
  if [[ "$KERNEL_ID" == "Linux" && -e /etc/os-release ]]; then
    . /etc/os-release
    echo "$KERNEL_ID/$ID"
  else
    echo "$KERNEL_ID"
  fi
}

get_os_dotfile_path() {
  local osid="$(get_os_id)"
  local osidpath="$DOTFILE_PATH/os/$osid"
  if [ ! -d "$osidpath" ]; then
		osid="$(dirname "$osid")"
    osidpath="$DOTFILE_PATH/os/$osid/generic"
		if [ ! -d "$osidpath" ]; then
			osidpath="$DOTFILE_PATH/os/generic)"
		fi
  fi
  echo $osidpath
}

add_os_rc() {
  THE_SHELL="$1"
  # fail silently if it doesn't exist
  . "$(get_os_dotfile_path)/.${THE_SHELL}rc" 2>/dev/null || true
}

for file in "$DOTFILE_PATH"/lib/helpers-*.sh; do
  . "$file"
done

. "$DOTFILE_PATH/lib/path.sh"

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -s "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"
