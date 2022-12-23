__TO_INSTALL=(
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
	xbps-query -Rl "$1" &> /dev/null
}

__pkg_install_all() {
	sudo xbps-install -Su && sudo xbps-install -Su
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
	test -n "$__INSTALLABLE" && confirm_cmd "sudo xbps-install -y $__INSTALLABLE"
}