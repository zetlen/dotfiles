#!/bin/bash

i_dont_have() {
	! command -v "$1" &>/dev/null
}

. "$HOME/.dotfiles/lib/logging.sh"

flog_success "Debian Linux detected. Using apt package manager."

confirm_then_sudo() {
	tosudo="sudo $*"
	fmted="$(printf 'Run %s%s%s ?' "$__flog_startul" "$tosudo" "$__flog_endul")"
	flog_confirm "$fmted" && eval "$tosudo"
}

is_available() {
	local to_check="$1"
	local apt_search_exp="$(printf '^%s$' "$to_check")"
	test -n "$(apt-cache search --names-only "$apt_search_exp")"
}

ensure_installed() {
	local installed_pkgs=()
	local unavailable_pkgs=()
	local to_install=()
	for pkg in "$@"; do
		if i_dont_have "$pkg"; then
			if is_available "$pkg"; then
				to_install+=("$pkg")
			else
				unavailable_pkgs+=("$pkg")
			fi
		else
			installed_pkgs+=("$pkg")
		fi
	done
	if (( ${#installed_pkgs[@]} )); then
		flog_success "Already installed: ${installed_pkgs[*]}"
	fi
	if (( ${#unavailable_pkgs[@]} )); then
		flog_error "Not found in repositories: ${unavailable_pkgs[*]}"
	fi
	if (( ${#to_install[@]} )); then
		confirm_then_sudo apt install -y ${to_install[@]}
	fi
}

confirm_then_sudo apt update
ensure_installed zsh git curl wget exa vim ripgrep fzf gnupg2 bat
