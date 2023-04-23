__TO_INSTALL=(
	zsh
	git
	curl
	lsof
	wget
	jq
	ripgrep
	fzf
	gnupg2
)

__pkg_is_installed() {
	dnf list --installed "$1" &> /dev/null
}

__pkg_is_available() {
	dnf info "$1" &> /dev/null
}

__pkg_install_all() {
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
	test -n "$__INSTALLABLE" && confirm_cmd "sudo dnf install -y $__INSTALLABLE"
}
