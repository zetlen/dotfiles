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

CURRENT_SHELL="$(ps -cp "$$" -o command="")"

# glob without breaking in any shell
ext_matches () {
	find "$DOTFILE_PATH"/lib/common -maxdepth 1 -name "*.${1}*" -print
}

# iterate through newline-delimited .sh files
while read -r file
do
	# only import *.sh version if there isn't one for the current shell
	[ -f "${file%.sh}"".$CURRENT_SHELL" ] || . "$file"
done < <(ext_matches sh)

# iterate through newline-delimited scripts for the current shell
while read -r file
do
	. "$file"
done < <(ext_matches $CURRENT_SHELL)

[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[ -s "$HOME/.asdf/asdf.sh" ] && . "$HOME/.asdf/asdf.sh"
