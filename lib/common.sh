#!/bin/sh

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
alias p="lpass show -c --password"
alias u="lpass show -c --username"
alias unixify="find . -type f -print0 | xargs -0 -n 1 -P 4 dos2unix"
alias exifkill="exiftool -all= "

export PATH="/usr/local/heroku/bin:$HOME/bin:/usr/local/share/npm/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:$HOME/.cargo/bin:$HOME/.yarn/bin:$PATH:$HOME/.composer/vendor/bin:$HOME/.rvm/bin"

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

colorlist() {
   for i in {0..255}; do print -Pn "%${i}F${(l:3::0:)i}%f " ${${(M)$((i%8)):#7}:+$'\n'}; done
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

DOTFILE_PATH="$HOME/.dotfiles/"

# POSIX-compatible sourcing
dotfile() {
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
