function configure_osx_as_zetlen() {
  read -p "Make OSX config tweaks? [y/N]" -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "NVRAM: Always verbose boot..." &&
    sudo nvram boot-args="-v" &&
    echo "LoginWindow: Set login message..." &&
    sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "a james zetlen joint 🕉" &&
    echo "Finder: Hide desktop icons..." &&
    defaults write com.apple.finder CreateDesktop false &&
    echo "Finder: Show hidden files..." &&
    defaults write com.apple.finder AppleShowAllFiles YES &&
    echo "Finder: Restart to take effect..." &&
    killall Finder
  fi
}

function update-vim {
  read -p "Are you sure? This quits all thine vims. [y/N]" -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    sudo killall vim 2> /dev/null
    brew upgrade && brew update && vim +PlugUpgrade +PlugUpdate +qall
  fi
}

function free-port {
  kill -9 $(lsof -t -i tcp:$1)
}