__TO_INSTALL=(
	zsh
	git
	curl
	lsof
	wget
	exa
	jq
	ripgrep
	fzf
	gnupg2
	bat
	vim
)

__pkg_is_available() {
	local to_check="$1"
	local apt_search_exp="$(printf '^%s$' "$to_check")"
	test -n "$(apt-cache search --names-only "$apt_search_exp")"
}
__pkg_install_all() {
	sudo locale-gen "en_US.UTF-8"
	sudo apt update
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
	test -n "$__INSTALLABLE" && confirm_cmd "sudo apt install -y $__INSTALLABLE"
}
