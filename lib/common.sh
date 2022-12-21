#!/bin/sh
# shellcheck disable=SC1090,SC1091
# tell shellcheck to quit complaining about dynamic paths

export LANG=en_US.UTF-8
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"

export SVN_EDITOR="vim"
export EDITOR="vim"

export JAVA_HOME
if [ -x "/usr/libexec/java_home" ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
fi

DOTFILE_PATH="$HOME/.dotfiles"

. "$DOTFILE_PATH/lib/path.sh"
. "$DOTFILE_PATH/lib/logging.sh"

for file in "$DOTFILE_PATH"/lib/common/*.sh; do
  . "$file"
done

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -s "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"
