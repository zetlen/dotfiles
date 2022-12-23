mdcd() {
  mkdir -p "$*" && cd "$*" || return
}

sizes() {
  local dir="${1:-.}"
  local depth="${2:-1}"
  du -chad "$depth" "$dir" | sort -h
}

i_dont_have() {
	! command -v "$1" &>/dev/null
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


if i_dont_have exa; then
	alias la='ls -lahAFG'
	alias l='ls -lahp'
	alias ls='ls -p'
else
  alias l='exa -lahF --color-scale --git'
  alias la='l --sort=accessed'
  alias lt='l --sort=modified'
fi

alias r='rsync -avhzPC' # skip .git and other common skips
alias rr='rsync -avhzP' # don't skip that
alias g=git
alias unixify="find . -type f -print0 | xargs -0 -n 1 -P 4 dos2unix"
alias wvim='vim -u ~/.vimrc_txt'