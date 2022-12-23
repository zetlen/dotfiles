__TO_INSTALL_FEDORA=(
	zsh
	git
	curl
	lsof
	wget
	exa
	jq
	vim-common
	vim-enhanced
	ripgrep
	fzf
	gnupg2
	bat
)

__pkg_is_installed() {
	dnf list --installed "$1" &> /dev/null
}

__pkg_is_available() {
	dnf info "$1" &> /dev/null
}
__pkg_install_all() {
	flog_success "Fedora Linux detected. Using dnf package manager."
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL_FEDORA[@]})"
	confirm_cmd "sudo dnf install -y $__INSTALLABLE"
}