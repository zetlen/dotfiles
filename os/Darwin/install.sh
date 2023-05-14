__TO_INSTALL=(
	coreutils
	exa
	fzf
	gnupg
	jq
	kaleidoscope
	openssl
	readline
	ripgrep
	sqlite3
	tcl-tk
	unzip
	vim
	xz
	zlib
)

__pkg_is_installed() {
	if [[ "$1" == "gnupg" ]]; then
		i_have gpg
	elif [[ "$1" == "kaleidoscope" ]]; then
		i_have ksdiff
	else
		brew list "$1" &>/dev/null
	fi
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

	flog_log "NVRAM: Always verbose boot..." &&
		sudo nvram boot-args="-v" &&
		flog_log "LoginWindow: Set login message..." &&
		sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "a james zetlen joint 🕉" &&
		flog_log "Finder: Hide desktop icons..." &&
		defaults write com.apple.finder CreateDesktop false &&
		flog_log "Finder: Show hidden files..." &&
		defaults write com.apple.finder AppleShowAllFiles YES &&
		flog_log "Keyboard: Normal key repeat and not special chars..." &&
		defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false &&
		flog_log "Finder: Restart to take effect..." &&
		killall Finder
}

__pkg_update_all() {
	brew update && brew upgrade
}
