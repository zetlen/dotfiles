__TO_INSTALL=(
	openssh
	zsh
	git
	curl
	lsof
	wget
	jq
	ripgrep
	fzf
	gnupg
	rustup
	unzip
)

__pkg_is_installed() {
	pacman -Qi "$1" &> /dev/null
}

__pkg_is_available() {
	local to_check="$1"
	local search_exp="$(printf '^%s$' "$to_check")"
	test -n "$(pacman -Ssq "$search_exp" | grep "$search_exp")"
}

__pkg_install_all() {
	sudo locale-gen && sudo pacman-key --init && sudo pacman-key --populate && sudo pacman -Sy --noconfirm archlinux-keyring
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
	test -n "$__INSTALLABLE" && confirm_cmd "sudo pacman -Sy --noconfirm $__INSTALLABLE"
}
