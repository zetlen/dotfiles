export SVN_EDITOR="vim"
export EDITOR="vim"

export HISTSIZE=1000000 # 1 million lines in history, why not?
export HISTCONTROL=ignoredups

alias la='ls -lahAFG'
alias l='ls -lahp'
alias ls='ls -p'
alias cd..='cd ..'
alias a='printf "\e]1;irc\a"; autossh -t -M 0 khmer@aram.xkcd.com "tmux attach -d"'
alias r="rsync -av -f\"- .git/\" --progress"
alias g=git
alias n=npm
alias e=mvim
alias emacs="/usr/local/bin/emacs"
alias unixify="find . -type f -print0 | xargs -0 -n 1 -P 4 dos2unix"
alias sb=subl

function tabcwd {
  tabname ${PWD##*/}
}

function tabname {
  printf "\e]1;$1\a"
}

function mdcd {
    mkdir -p $1 && cd $1
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
if [ -z "$1" ]
    then
        echo "Supply an extension"
    else
        ext="*.${1}"
        find . -name $ext -exec rm -r {} \;
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
  if [[ -e "$(git rev-parse --git-dir 2> /dev/null)" ]]; then
    tabcwd
    echo " [\[\033[0;36m\]$(git describe --tags --always 2> /dev/null)\[\033[0;37m\]]"
  fi
}
gitprompt_shell=~/.bash-git-prompt/gitprompt.sh
if [ -f $gitprompt_shell ]; then
  GIT_PROMPT_THEME="Custom"
  . $gitprompt_shell
  if [ -f ~/.git-completion.bash ]; then
    . ~/.git-completion.bash
    __git_complete g __git_main
  elif [ -f /etc/bash_completion.d/git ]; then
    . /etc/bash_completion.d/git
    __git_complete g __git_main
  fi
else
  echo "Git prompt not found. Run this: git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt"
fi

export PATH=/usr/local/share/npm/bin:/opt/local/bin:/opt/local/sbin:$PATH

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

[ ! -f ~/.bashrc.local  ] || . ~/.bashrc.local
