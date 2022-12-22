__TO_INSTALL_MACOS=(
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

__pkg_is_available() {
	brew info "$1" &> /dev/null
}

flog_success "MacOS detected."

if i_dont_have git; then
	flog_warn "git isn't installed."
	confirm_cmd "xcode-select --install"
fi
if i_dont_have brew; then
	flog_warn "brew isn't installed."
	confirm_cmd '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'
fi

__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL_MACOS[@]})"
confirm_cmd "brew install $__INSTALLABLE"