__TO_INSTALL_FEDORA=(
	zsh
	git
	curl
	lsof
	wget
	exa
	jq
	vim
	ripgrep
	fzf
	gnupg2
	bat
)

__pkg_is_available() {
	dnf info "$1" &> /dev/null
}

flog_success "Fedora Linux detected. Using dnf package manager."
__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL_FEDORA[@]})"
confirm_cmd "sudo dnf install -y $__INSTALLABLE"

