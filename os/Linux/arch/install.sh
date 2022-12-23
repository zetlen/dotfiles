__TO_INSTALL=(
	openssh
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
	pacman -Qi "$1" &> /dev/null
}

__pkg_is_available() {
	local to_check="$1"
	local apt_search_exp="$(printf '^%s$' "$to_check")"
	test -n "$(pacman -Ss "$apt_search_exp")"
}

__pkg_install_all() {
	sudo pacman-key --init && sudo pacman-key --populate && sudo pacman -Sy --noconfirm archlinux-keyring
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
	test -n "$__INSTALLABLE" && confirm_cmd "sudo pacman -Sy --noconfirm $__INSTALLABLE"
}