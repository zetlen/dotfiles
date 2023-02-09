__TO_INSTALL=(
	zsh
	git
	curl
	lsof
	wget
	exa
	jq
	vim
	vim-data
	ripgrep
	fzf
	gpg2
	bat
)

__pkg_is_installed() {
	zypper search --installed-only "$1" &> /dev/null
}

__pkg_is_available() {
	zypper search --match-exact "$1" &> /dev/null
}

__pkg_install_all() {
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
	test -n "$__INSTALLABLE" && confirm_cmd "sudo zypper install -y $__INSTALLABLE"
}
