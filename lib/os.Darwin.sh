#!/bin/sh

take_osx_config_snapshot() {
  manualSettingsDir="$DOTFILE_PATH/lib/settings/darwin"
  tar -cvvvPf darwin.snapshot.tar -T "$DOTFILE_PATH/lib/snapshots/darwin.txt"
  if [ -d "$manualSettingsDir" ] && [ -n "$(ls $manualSettingsDir)" ]; then
    tarPath="$(pwd)/darwin.snapshot.tar"
    cd "$manualSettingsDir" && tar -rf "$tarPath" ./* && cd - || return
  fi
  tar -tvf darwin.snapshot.tar
}

apply_osx_config_snapshot() {
  tar -xvvvwPf "$1"
}

configure_osx_as_zetlen() {
  read -p "Make OSX config tweaks? [y/N]" -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "NVRAM: Always verbose boot..." &&
      sudo nvram boot-args="-v" &&
      echo "LoginWindow: Set login message..." &&
      sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "a james zetlen joint 🕉" &&
      echo "Finder: Hide desktop icons..." &&
      defaults write com.apple.finder CreateDesktop false &&
      echo "Finder: Show hidden files..." &&
      defaults write com.apple.finder AppleShowAllFiles YES &&
      echo "Keyboard: Normal key repeat and not special chars..." &&
      defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false &&
      echo "Finder: Restart io take effect..." &&
      killall Finder
  fi
}

update_vim() {
  echo "Are you sure? This quits all thine vims. [y/N]"
  read -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo killall vim 2>/dev/null
    if brew upgrade && brew update && vim +PlugUpgrade +PlugUpdate +qall; then
      read -p "Try to compile YouCompleteMe with cd ~/.vim/plugged/YouCompleteMe/ && ./install.py --js-completer?" -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo Installing YouCompleteMe...
        cd ~/.vim/plugged/YouCompleteMe/ && ./install.py --js-completer
      fi
    fi
  fi
}

free_port() {
  kill -9 "$(lsof -t -i tcp:"$1")"
}

if [ "$IN_TMUX" -eq "1" ]; then
  tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel pbcopy
fi

random_word() {
  perl -e 'srand; rand($.) < 1 && ($line = $_) while <>; print $line;' /usr/share/dict/words
}

googlebot() {
  # tell shellcheck to allow this stupid command to run forever
  # shellcheck disable=2207
  voices=($(say -v '?' | awk '{print $1}'))
  while :; do random_word | tee /dev/tty | say -v "${voices[$RANDOM % ${#voices[@]}]}"; done
}
