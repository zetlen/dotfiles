__TO_INSTALL=(
	exa
	vim
	ripgrep
	fzf
	gnupg
	bat
	bitwarden-cli
	coreutils
	kaleidoscope
	jq
)

__pkg_is_installed() {
	brew list "$1" &> /dev/null
}

__pkg_is_available() {
	brew info "$1" &> /dev/null
}

flog_success "MacOS detected."

__pkg_install_all() {
	if i_dont_have git; then
		flog_warn "git isn't installed."
		confirm_cmd "xcode-select --install"
	fi
	if i_dont_have brew; then
		flog_warn "brew isn't installed."
		confirm_cmd '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'
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