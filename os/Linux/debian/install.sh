__TO_INSTALL_DEBIAN=(
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
	local to_check="$1"
	local apt_search_exp="$(printf '^%s$' "$to_check")"
	test -n "$(apt-cache search --names-only "$apt_search_exp")"
}
__pkg_install_all() {
flog_success "Debian Linux detected. Using apt package manager."
__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL_DEBIAN[@]})"
test -n "$__INSTALLABLE" && confirm_cmd "sudo apt update && sudo apt install -y $__INSTALLABLE"
}
