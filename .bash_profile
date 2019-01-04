# tell shellcheck to allow conditional sourcing
# shellcheck disable=1090 

export SVN_EDITOR="vim"
export EDITOR="vim"

export HISTSIZE=1000000 # 1 million lines in history, why not?
export HISTCONTROL=ignoredups

export COLONPIPE="zetlen@colonpipe.org:~/colonpipe.org/"

if command -v tmux > /dev/null && [[ $TERM =~ screen ]] && [ -n "$TMUX" ]; then
  IN_TMUX="1"
else
  IN_TMUX=
fi

alias la='ls -lahAFG'
alias l='ls -lahp'
alias ls='ls -p'
alias cd..='cd ..'
alias a='printf "\e]1;irc\a"; autossh -t -M 0 khmer@aram.xkcd.com "tmux attach -d -t irssi || tmux new -s irssi"'
alias r="rsync -av -f\"- .git/\" --progress"
alias g=git
alias p="lpass show -c --password"
alias u="lpass show -c --username"
alias t='task'
alias someday='task add +someday'
alias unixify="find . -type f -print0 | xargs -0 -n 1 -P 4 dos2unix"
alias exifkill="exiftool -all= "

. ~/.dotfiles/lib/helpers-node.sh

function tma {
  if [[ "$IN_TMUX" -eq "1" ]]; then
    echo Already in tmux.
    return 1
  fi
  sname=$1;
  if [ -z "$1" ]; then
    sname="main";
  fi
  tmux attach -d -t $sname || tmux new -s $sname 
}

function human-duration {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  (( D > 0 )) && printf '%d days ' $D
  (( H > 0 )) && printf '%d hours ' $H
  (( M > 0 )) && printf '%d minutes ' $M
  (( D > 0 || H > 0 || M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

function exists {
  declare -f -F "$1" > /dev/null
  return $?
}

function winname {
  printf "\\e]1;%s\\a" "$1"
}

function tmuxwinname {
  if [[ "$IN_TMUX" -eq "1" ]]; then
    tmux rename-window "$1"
  fi
}

function mdcd {
    mkdir -p "$*" && cd "$*" || return
}

function random_word {
  perl -e 'srand; rand($.) < 1 && ($line = $_) while <>; print $line;' /usr/share/dict/words
}

function googlebot {
  # tell shellcheck to allow this stupid command to run forever
  # shellcheck disable=2207
  voices=($(say -v '?' | awk '{print $1}')); while :; do random_word | tee /dev/tty | say -v "${voices[$RANDOM % ${#voices[@]} ]}"; done
}

function tmux_winname_randomword {
  tmuxwinname "$(random_word)"
}

function sprunge {
    if [ "$*" ]; then
      local prompt;
      prompt="$(PS1="$PS1" bash -i <<<$'\nexit' 2>&1 | head -n1)"
        ( echo "$(sed 's/\o033\[[0-9]*;[0-9]*m//g'  <<<"$prompt")$*"; exec "$@"; )
    else
        cat
    fi | curl -s -F 'sprunge=<-' http://sprunge.us
}

function rmext() {
  if [ -z "$1" ]; then
    echo "Supply an extension"
  else
    ext="*.${1}"
    find . -name "$ext" -exec rm -r {} \;
  fi
}

# narrow down ifconfig output to find roughly my ip
alias myip="ifconfig | grep -E '(192|10)'"

function prompt_callback() {
  local EXTRAS; EXTRAS=" / » "
  local TASKCTX; TASKCTX=$(task _get rc.context 2> /dev/null)
  if exists 2m-status; then
    TASKSTATUS=$(2m-status -s)
    if [ -n "$TASKSTATUS" ]; then EXTRAS="\\n   \\[\\033[7m\\]2m task in progress: ${TASKSTATUS}\\n\\[\\033[0m\\]${EXTRAS}"; fi
  fi
  if [[ -n $TASKCTX ]]; then
    EXTRAS="${EXTRAS} \\[\\033[0;32m\\][t: \\[\\033[0;37m\\]${TASKCTX}\\[\\033[0;32m\\]]"
  fi
  local GITDIR; GITDIR="$(git rev-parse --show-toplevel 2> /dev/null)"
  if [[ -e $GITDIR ]]; then
    GIT_DESCRIBE_OUTPUT=$(git describe --tags --always 2> /dev/null)
    export GIT_REPO_SUMMARY="[$GITDIR:$GIT_DESCRIBE_OUTPUT]"
    tmuxwinname "[$(basename "$GITDIR")]"
    EXTRAS="${EXTRAS} [\\[\\033[0;36m\\]${GIT_DESCRIBE_OUTPUT}\\[\\033[0;37m\\]]"
  fi
  if [[ -n "$EXTRAS" ]]; then echo "$EXTRAS"; fi
}

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
elif [ -f /etc/bash_completion.d/git ]; then
  # tell shellcheck to stop complaining about conditional includes
  # shellcheck disable=1091
  . /etc/bash_completion.d/git
fi
exists __git_complete && __git_complete g __git_main

exists _task && complete -o nospace -F _task t

__lpass_complete_name()
{
    local cur="$2"
    local matches

    # matches on full path
    matches=$(lpass ls --sync=no | grep -E "^$cur" | awk '{print $1}')
    # matches on leaves
    matches+=$(lpass ls --sync=no | grep -E "/$cur" | sed -e "s/ \\[id.*//g" | \
               awk -F '/' '{print $NF}')

    while IFS=$'\n' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$matches" "$cur")
}

complete -o default -F __lpass_complete_name p
complete -o default -F __lpass_complete_name u
complete -o default -F __lpass_complete_name 'lpass show'

export PATH=$HOME/bin:/usr/local/share/npm/bin:/opt/local/bin:/opt/local/sbin:/usr/local/sbin:$PATH

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

[ ! -f ~/.bashrc ] || . ~/.bashrc

OSRC=~/.dotfiles/lib/os.$(uname).bashrc

if [ ! -f "$OSRC" ]; then
  printf "No OS-specific bashrc at %s\\n" "$OSRC"
else
  . "$OSRC"
fi

[ ! -f ~/.bashrc.local  ] || . ~/.bashrc.local

if command -v tmux>/dev/null; then
	tmux_winname_randomword
fi

