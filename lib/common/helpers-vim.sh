#!/bin/sh

__update_vim_package_manager() {
  echo Finding package manager...
  if command -v dnf; then
    sudo dnf update vim
  elif command -v apt-get; then
    sudo apt-get update && sudo apt-get upgrade vim
  elif command -v brew; then
    brew update && brew upgrade;
  fi
}

update_vim() {
  echo "Are you sure? This quits all thine vims. [y/N]"
  read -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo killall vim 2>/dev/null
    if __update_vim_package_manager && vim +PlugUpgrade +PlugUpdate +qall; then
      echo "Try to compile YouCompleteMe with cd ~/.vim/plugged/YouCompleteMe/ && python3 ./install.py --all? [y/N]"
			read -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo Installing YouCompleteMe...
        cd ~/.vim/plugged/YouCompleteMe/ && python3 ./install.py --all
      fi
    fi
  fi
}
