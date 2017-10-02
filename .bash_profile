export SVN_EDITOR="vim"
export EDITOR="vim"

export HISTSIZE=1000000 # 1 million lines in history, why not?
export HISTCONTROL=ignoredups

export COLONPIPE="zetlen@colonpipe.org:~/colonpipe.org/"

alias la='ls -lahAFG'
alias l='ls -lahp'
alias ls='ls -p'
alias cd..='cd ..'
alias a='printf "\e]1;irc\a"; autossh -t -M 0 khmer@aram.xkcd.com "tmux attach -d -t irssi || tmux new -s irssi"'
alias r="rsync -av -f\"- .git/\" --progress"
alias g=git
alias n=npm
alias nr='npm run'
alias nenv='printf "node $(node -v)\nnpm $(npm -v)\nyarn $(yarn --version)\n"'
alias y=yarn
alias yr='yarn run'
alias p="lpass show -c --password"
alias t='task'
alias someday='task add project:Personal.MonthlyTickler wait:1m'
alias unixify="find . -type f -print0 | xargs -0 -n 1 -P 4 dos2unix"
alias pwnusr="sudo chown -R $(whoami) /usr/local"
alias killexif="exiftool -all= "

function tosomeday {
  task $1 modify project:Personal.MonthlyTickler wait:1m +someday
}

function two-minute-rule {
  local warning="display notification \"${*}\" with title"
  {
    for i in {4..1}; do
      left=$(expr $i \* 30)
      osascript -e "$warning \"${left}s left\"";
      sleep 30;
    done;
    osascript -e "$warning \"Time expired\"";
  } & disown
}
alias 2mr='two-minute-rule'

function 2mt {
  2mr $(task _get ${1}.description)
}

function tma {
  sname=$1;
  if [ -z "$1" ]; then
    sname="main";
  fi
  tmux attach -d -t $sname || tmux new -s $sname
}

function update-vim {
  read -p "Are you sure? This quits all thine vims. [y/N]" -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    sudo killall vim 2> /dev/null
    brew upgrade && brew update && vim +PluginUpdate +qall && ~/.vim/bundle/YouCompleteMe/install.py --tern-completer
  fi
}

function free-port {
  kill -9 $(lsof -t -i tcp:$1)
}

function exists {
  declare -f -F $1 > /dev/null
  return $?
}

function winname {
  printf "\e]1;$1\a"
}

function tmuxwinname {
  tmux rename-window $1
}

function mdcd {
    mkdir -p $1 && cd $1
}

function random_word {
  perl -e 'srand; rand($.) < 1 && ($line = $_) while <>; print $line;' /usr/share/dict/words
}

function googlebot {
voices=($(say -v '?' | awk '{print $1}')); while :; do random_word | tee /dev/tty | say -v ${voices[$RANDOM % ${#voices[@]} ]}; done
}

function tmux_winname_randomword {
  tmuxwinname `random_word`
}

function sprunge {
    if [ "$*" ]; then
        local prompt="$(PS1="$PS1" bash -i <<<$'\nexit' 2>&1 | head -n1)"
        ( echo "$(sed 's/\o033\[[0-9]*;[0-9]*m//g'  <<<"$prompt")$@"; exec $@; )
    else
        cat
    fi | curl -s -F 'sprunge=<-' http://sprunge.us
}

function rmext() {
  if [ -z "$1" ]; then
    echo "Supply an extension"
  else
    ext="*.${1}"
    find . -name $ext -exec rm -r {} \;
  fi
}

function configure_osx_as_zetlen() {
  read -p "Make OSX config tweaks? [y/N]" -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "NVRAM: Always verbose boot..." &&
    sudo nvram boot-args="-v" &&
    echo "LoginWindow: Set login message..." &&
    sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "🕉" &&
    echo "Finder: Hide desktop icons..." &&
    defaults write com.apple.finder CreateDesktop false &&
    echo "Finder: Show hidden files..." &&
    defaults write com.apple.finder AppleShowAllFiles YES &&
    echo "Finder: Restart to take effect..." &&
    killall Finder
  fi
}

alias ..='cd ..' # up a directory
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'
alias -- -="cd -" # - to go back
# narrow down ifconfig output to find roughly my ip
alias myip="ifconfig | grep -E '(192|10)'"

function prompt_callback() {
  local EXTRAS="/ » "
  local TASKCTX=$(task _get rc.context 2> /dev/null)
  if [[ -n $TASKCTX ]]; then
    EXTRAS="${EXTRAS} \[\033[0;32m\][t: \[\033[0;37m\]${TASKCTX}\[\033[0;32m\]]"
  fi
  local GITDIR=$(git rev-parse --show-toplevel 2> /dev/null)
  if [[ -e $GITDIR ]]; then
    tmuxwinname "[$(basename $GITDIR)]"
    EXTRAS="${EXTRAS} [\[\033[0;36m\]$(git describe --tags --always 2> /dev/null)\[\033[0;37m\]]"
  fi
  if [[ -n $EXTRAS ]]; then echo $EXTRAS; fi
}

gitprompt_shell=~/.bash-git-prompt/gitprompt.sh
if [ -f $gitprompt_shell ]; then
  GIT_PROMPT_THEME="Custom"
  # GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh
  GIT_PROMPT_SHOW_UNTRACKED_FILES=no
  GIT_PROMPT_FETCH_REMOTE_STATUS=0
  . $gitprompt_shell
else
  echo "Git prompt not found. Run this: git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt"
fi
if [ -f $(brew --prefix 2> /dev/null)/etc/bash_completion ]; then
  . $(brew --prefix 2> /dev/null)/etc/bash_completion
fi
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
elif [ -f /etc/bash_completion.d/git ]; then
  . /etc/bash_completion.d/git
fi
exists __git_complete && __git_complete g __git_main

exists _task && complete -o nospace -F _task t

__lpass_complete_name()
{
    local cur=$2
    local matches

    # matches on full path
    matches=$(lpass ls | egrep "^$cur" | awk '{print $1}')
    # matches on leaves
    matches+=$(lpass ls | egrep "/$cur" | sed -e "s/ \[id.*//g" | \
               awk -F '/' '{print $NF}')

    local IFS=$'\n'
    COMPREPLY=($(compgen -W "$matches" "$cur"))
    if [[ ! -z $COMPREPLY ]]; then
        COMPREPLY=($(printf "%q\n" "${COMPREPLY[@]}"))
    fi
}
complete -o default -F __lpass_complete_name p

export PATH=$HOME/bin:/usr/local/share/npm/bin:/opt/local/bin:/opt/local/sbin:/usr/local/sbin:$PATH

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

[ ! -f ~/.bashrc.local  ] || . ~/.bashrc.local

# if command -v tmux>/dev/null; then
# 	[[ ! $TERM =~ screen ]] && [ -z $TMUX ] && t || tmux_winname_randomword
# fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
