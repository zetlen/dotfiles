REPO=$(git rev-parse --show-toplevel)
REPONAME=$(basename $REPO)
EXPECTED_REPONAME=".dotfiles"
if [ $REPONAME != $EXPECTED_REPONAME ]; then
  echo Do not run this script in directories not inside the $EXPECTED_REPONAME repo.
  exit 1
fi
COPIED=0

for file in ${REPO}/.*; do
  FILENAME=$(basename "$file");
  TARGET=~/"$FILENAME";
  for nocopy in . .. .git .gitignore; do
    if [ "$FILENAME" == "$nocopy" ]; then
      echo Skipping $nocopy;
      continue 2;
    fi
  done
  if [ "${FILENAME##*.}" == "swp" ]; then
    continue;
  fi
  if [ -L "$TARGET" ]; then
    echo Removing existing symlink "$TARGET"
    rm $TARGET;
  elif [ -e "$TARGET" ]; then
    echo Not symlinking $FILENAME because $TARGET already exists.
    continue;
  fi
  echo Symlinking $FILENAME;
  ln -s "$file" "$TARGET" && COPIED=$((COPIED+1));
done

if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim;
fi
echo $COPIED dotfiles symlinked to homedir.

if [ ! -f ~/.git-completion.bash ]; then
  curl https://cdn.rawgit.com/git/git/master/contrib/completion/git-completion.bash > ~/.git-completion.bash
fi

write_taskrc() {
  printf 'include ~/.dotfiles/inc.%s.taskrc\n' $1 > ~/.taskrc
}

if which task > /dev/null; then
  if [ -a ~/.taskrc ]; then
    read -p "Overwrite existing .taskrc? Y/n" -n 1 -r
    echo    # (optional) move to a new line
    [[ $REPLY =~ ^[Yy]$ ]] && write_taskrc "default";
  else
    write_taskrc "default";
  fi
fi

