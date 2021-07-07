source "$HOME/.dotfiles/lib/common.sh"

function require_tools() {
  MISSING_TOOLS=()
  while read $REQUIRED_TOOL; do
    command -v $REQUIRED_TOOL >/dev/null
    if [ "$?" -ne "0" ]; then
      MISSING_TOOLS+=("$REQUIRED_TOOL")
    fi
  done <$1
  if [ ${#MISSING_TOOLS} -ne '0' ]; then
    echo Install these missing tools for everything to work:
    for TOOL in ${MISSING_TOOLS[@]}; do echo $TOOL; done
    return 1
  fi
}

REPO=$(git rev-parse --show-toplevel)
REPONAME=$(basename $REPO)
EXPECTED_REPONAME=".dotfiles"
if [ $REPONAME != $EXPECTED_REPONAME ]; then
  echo Do not run this script in directories not inside the $EXPECTED_REPONAME repo.
  exit 1
fi
COPIED=0

for file in ${REPO}/.*; do
  FILENAME=$(basename "$file")
  TARGET=~/"$FILENAME"
  for nocopy in . .. .git .gitignore; do
    if [ "$FILENAME" == "$nocopy" ]; then
      echo Skipping $nocopy
      continue 2
    fi
  done
  if [ "${FILENAME##*.}" == "swp" ]; then
    continue
  fi
  if [ -L "$TARGET" ]; then
    echo Removing existing symlink "$TARGET"
    rm $TARGET
  elif [ -e "$TARGET" ]; then
    echo Not symlinking $FILENAME because $TARGET already exists.
    continue
  fi
  echo Symlinking $FILENAME
  ln -s "$file" "$TARGET" && COPIED=$((COPIED + 1))
done


if [ ! -d ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
echo $COPIED dotfiles symlinked to homedir.

if [ -s "$BASH_VERSION" ] && [ ! -f ~/.git-completion.bash ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash >~/.git-completion.bash
fi

OSNAME="$(uname)"

OSREQUIRED="$DOTFILE_PATH/lib/os.${OSNAME}.required_tools.txt"

[ -f "$OSREQUIRED" ] && require_tools $OSREQUIRED
