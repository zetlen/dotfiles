__TO_INSTALL=(
	automake
	bzip2
	curl
	eza
	findutils
	fzf
	gcc
	gdbm-devel
	git
	gpg2
	jq
	libbz2-devel
	libffi-devel
	lsof
	make
	ncurses-devel
	openssl-devel
	readline-devel
	ripgrep
	sqlite3-devel
	tk-devel
	unzip
	vim
	wget
	xz
	xz-devel
	zlib-devel
	zsh
)

__pkg_is_installed() {
	zypper search --installed-only "$1" &>/dev/null
}

__pkg_is_available() {
	zypper search --match-exact "$1" &>/dev/null
}

__pkg_install_all() {
	sudo zypper install -t pattern devel_basis
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
	test -n "$__INSTALLABLE" && confirm_cmd "sudo zypper install -y $__INSTALLABLE"
}

__pkg_update_all() {
	sudo zypper ref && sudo zypper update
}
