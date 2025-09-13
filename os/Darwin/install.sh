__TO_INSTALL=(
    amethyst
    bat
    cmake
    coreutils
    eza
    figlet
    fzf
    git-delta
    git-lfs
    jq
    kaleidoscope
    openjdk
    openssl
    readline
    ripgrep
    sqlite3
    tcl-tk
    tea
    unzip
    xz
    zlib
    iterm2
    font-victor-mono-nerd-font
    gpg-suite
    istat-menus
)

__pkg_is_installed() {
    case "$1" in
    "gnupg")
        i_have_gpg
        ;;
    "kaleidoscope")
        i_have ksdiff || [ -d "/Applications/Kaleidoscope.app" ]
        ;;
    "amethyst")
        [ -d "/Applications/Amethyst.app" ]
        ;;
    *) brew list "$1" &>/dev/null ;;
    esac
}

__pkg_is_available() {
    brew info "$1" &>/dev/null
}

__pkg_install_all() {
    if i_dont_have git; then
        flog_warn "git isn't installed."
        confirm_cmd "xcode-select --install"
    fi
    if i_dont_have brew; then
        flog_warn "brew isn't installed."
        confirm_cmd '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    fi

    __INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
    test -n "$__INSTALLABLE" && confirm_cmd "brew install $__INSTALLABLE"

    __zlogin_msg=

    flog_log "Always verbose boot..."
    confirm_cmd 'sudo nvram boot-args="-v"'
    flog_log "Hide desktop icons..."
    confirm_cmd 'defaults write com.apple.finder CreateDesktop false'
    flog_log "Show hidden files..."
    confirm_cmd 'defaults write com.apple.finder AppleShowAllFiles YES'
    flog_log "Keyboard: Normal key repeat and not special chars..."
    confirm_cmd 'defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false'
    flog_log "Set cheeky login text..."
    confirm_cmd 'sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "a james zetlen joint 🕉"'

    killall Finder
}

__pkg_update_all() {
    brew update && brew upgrade
}
