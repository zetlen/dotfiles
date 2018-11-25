# tell shellcheck to allow conditional sourcing
# shellcheck disable=1090 

take_osx_config_snapshot() {
  manualSettingsDir=~/.dotfiles/lib/settings/darwin
  tar -cvvvPf darwin.snapshot.tar -T ~/.dotfiles/lib/snapshots/darwin.txt
  if [[ -d "$manualSettingsDir" ]] && [[ -n "$(ls $manualSettingsDir)" ]]; then
    tarPath="$(pwd)/darwin.snapshot.tar"
    cd "$manualSettingsDir" && tar -rf "$tarPath" ./* && cd - || return
  fi
  tar -tvf darwin.snapshot.tar
}

apply_osx_config_snapshot() {
  tar -xvvvwPf "$1"
}

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
    echo "Keyboard: Normal key repeat and not special chars..." && 
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false &&
    echo "Finder: Restart io take effect..." &&
    killall Finder
  fi
}

function update-vim {
  read -p "Are you sure? This quits all thine vims. [y/N]" -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    sudo killall vim 2> /dev/null
    if brew upgrade && brew update && vim +PlugUpgrade +PlugUpdate +qall; then
      read -p "Try to compile YouCompleteMe with cd ~/.vim/plugged/YouCompleteMe/ && ./install.py --js-completer?" -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]
      then
        echo Installing YouCompleteMe...
        cd ~/.vim/plugged/YouCompleteMe/ && ./install.py --js-completer
      fi
    fi
  fi
}

function free-port {
  kill -9 "$(lsof -t -i tcp:"$1")"
}

tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel pbcopy

__HOMEBREW_PREFIX=$(brew --prefix 2> /dev/null)
if [ -f "$__HOMEBREW_PREFIX/opt/bash-git-prompt/share/gitprompt.sh" ]; then
    __GIT_PROMPT_DIR="$__HOMEBREW_PREFIX/opt/bash-git-prompt/share"
    export GIT_PROMPT_THEME="Custom"
    # GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh
    export GIT_PROMPT_SHOW_UNTRACKED_FILES=no
    export GIT_PROMPT_FETCH_REMOTE_STATUS=0
    source "$__GIT_PROMPT_DIR/gitprompt.sh"
else
  echo "Git prompt not found. Run brew install bash-git-prompt"
fi
if [[ -f ${__HOMEBREW_PREFIX}/etc/bash_completion ]]; then
  . "${__HOMEBREW_PREFIX}/etc/bash_completion"
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
