. "$HOME/.dotfiles/lib/installing.sh"

declare -a _z_updaters

_z_updaters[1]="OS packages"
_z_update1() {
	flog_log "Finding package update routing for $OSNAME..."
	if [ ! -e "${OSPATH}/install.sh" ]; then
		flog_warn "No update script for OS "$OSNAME" present."
	else
		. "${OSPATH}/install.sh" || die_bc "Error running install script ${OSPATH}/install.sh"
		flog_success "Found ${OSPATH}/install.sh"
		__pkg_update_all
	fi
}

_z_updaters[2]="ZSH plugins"
_z_update2() {
	zsh-plugin-update
}

_z_updaters[3]="mise and tool versions"
_z_update3() {
  mise self-update --yes
  mise plugins update --yes
  mise up --yes
}

_z_updaters[4]="Rust toolchain and packages"
_z_update4() {
	rustup update
	cargo install cargo-update
	cargo install-update -a
}

_z_updaters[5]="Go toolchain and packages"
_z_update5() {
	go install github.com/Gelio/go-global-update@latest
	go-global-update
}

_z_updaters[6]="astronvim"
_z_update6() {
	nvim +AstroUpdate +AstroUpdatePackages +quitall
}

_z_updaters[7]="vim plugins"
_z_update7() {
	vim +PlugUpgrade +PlugUpdate +qall
}

zsh-update-all() {
  if [[ "$1" == "-y" ]]; then
    export FLOG_CONFIRM_ALL=1
  fi
	local fn
	local desc
  local TOTAL_STEPS="$#_z_updaters"
	for ((i = 1; i <= $TOTAL_STEPS; i++)) do
		fn="_z_update$i"
		desc="${_z_updaters[$i]}"
		echo ''
		flog_log "${__flog_color_standout}Update ${desc}${__flog_color_normal} ($i of $TOTAL_STEPS)"
		if flog_confirm "Proceed?"; then
			flog_indent 2
			"$fn"
			flog_indent -2
		fi
	done
}
