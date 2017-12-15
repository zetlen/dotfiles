function configure_osx_as_zetlen() {
  read -p "Make OSX config tweaks? [y/N]" -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    echo "NVRAM: Always verbose boot..." &&
    sudo nvram boot-args="-v" &&
    echo "LoginWindow: Set login message..." &&
    sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "🕉" &&
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

function __2m_notify {
  if [ -z "$1" ]; then
    tmux source-file ~/.tmux.conf
    return $?
  fi
  local msg="$1"
  local title=""
  local left="$2"
  local duration=$(2m status -t)
  local status=0

  case 1:${left:--} in
    ($((left<0))*)
      title="${duration} ⏱  ${left#-}s over 😬"
      tmux set -g status-left-bg colour0
      tmux set -g status-left-fg colour196
    ;;
    (1:*[!0-9]*|1:0*[89]*)
      msg="Error in __2m_notify script; \$left was $left"
      title="2m error"
      status=1
      tmux set -g status-left-bg colour9
      tmux set -g status-left-fg colour255
    ;;
    ($((left>0))*)
      title="${duration} ⏱ "
      tmux set -g status-left-bg colour0
      tmux set -g status-left-fg colour83
    ;;
    ($((left==0))*)
      title='Two minutes are up 😤 WYD'
      tmux set -g status-left-bg colour0
      tmux set -g status-left-fg colour226
    ;;
  esac

  local applescript="display notification \"${msg}\" with title \"${title}\""
  if ! osascript -e "$applescript"; then echo "Error in applescript: $applescript"; fi
  local tmsg="\t📝  $msg 💬  \t $title "
  tmux set -g status-left-length ${#tmsg}
  tmux set -g status-left "$tmsg"

  return $status
}
. ~/.dotfiles/lib/2m/2m.sh
