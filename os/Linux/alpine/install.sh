__TO_INSTALL=(
	alpine-sdk
	curl
	fzf
	git
	gnupg
	jq
	lsof
	openssh
	openssl
	ripgrep
	tk
	unzip
	vim
	wget
	xz
	zlib
	zsh
)

__pkg_is_installed() {
	apk info "$1" &>/dev/null
}

__pkg_is_available() {
	test -n "$(apk search -e "$1")"
}

__pkg_install_all() {
	apk update
	apk upgrade
	__INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
	test -n "$__INSTALLABLE" && confirm_cmd "apk add $__INSTALLABLE"
}

__pkg_update_all() {
	sudo apk update && sudo apk upgrade
}
