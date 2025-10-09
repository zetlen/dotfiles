mdcd() {
    mkdir -p "$*" && cd "$*" || return
}

sizes() {
    local dir="${1:-.}"
    local depth="${2:-1}"
    du -chd "$depth" "$dir" | sort -h
}

find_up() {
    local path=$(pwd)
    while [[ "$path" != "" && ! -e "$path/$1" ]]; do
        path=${path%/*}
    done
    echo "$path"
}

i_have() {
    command -v "$1" &>/dev/null
}

i_dont_have() {
    ! i_have "$1"
}

in_repo() {
    i_have git && git rev-parse HEAD &>/dev/null
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
    the__path="$(echo "$the__path" | tr -s /)"

    # Remove all /./ sequences.
    the__path="${the__path//\/.\//\/}"

    # Remove any final trailing slash.
    echo "${the__path%/}"
}

# ls
if i_dont_have eza; then
    alias la='ls -lahAFG'
    alias l='ls -lahp'
    alias ls='ls -p'
else
    alias l='eza -lahF --color-scale --git --icons always '
    alias la='l --sort=accessed'
    alias lt='l --sort=modified'
    alias lb='l --sort=size'
fi

alias r='rsync -avhzPC' # skip .git and other common skips
alias rr='rsync -avhzP' # don't skip that

alias m="mise"
alias mr="mise run "

alias g=git
into() {
    if [ -z "$ZELLIJ" ]; then
        ssh -o RequestTTY=force $1 -- "zsh -lc 'mise x -- zellij attach -c $(hostname -s)'"
    else
        ssh -o RequestTTY=force $1
    fi
}
