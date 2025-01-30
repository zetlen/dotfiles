. "$HOME/.dotfiles/lib/installing.sh"

zsh-update-all() {

  _z_update__1_os_packages() {
    flog_log "Finding package update routing for $OSNAME..."
    if [ ! -e "${OSPATH}/install.sh" ]; then
      flog_warn "No update script for OS "$OSNAME" present."
    else
      . "${OSPATH}/install.sh" || die_bc "Error running install script ${OSPATH}/install.sh"
      flog_success "Found ${OSPATH}/install.sh"
      __pkg_update_all
    fi
  }

  _z_update__2_zsh_plugins() {
    zsh-plugin-update
  }

  _z_update__3_mise_and_tool_versions() {
    mise self-update --yes
    mise plugins update --yes
    mise up --yes
    mise prune --yes
  }

  _z_update__4_rust_toolchain() {
    rustup update
    cargo install cargo-update
    cargo install-update -a
  }

  _z_update__5_go_toolchain() {
    go install github.com/Gelio/go-global-update@latest
    go-global-update
  }

  _z_update__6_vim_plugins() {
    vim +PlugUpgrade +PlugUpdate +qall
  }

  if [[ "$1" == "-y" ]]; then
    export FLOG_CONFIRM_ALL=1
  fi
  local updaters=($(typeset -fm + '_z_update__*'))
  local updater
  local total_steps="$#updaters"
  for ((i = 1; i <= $total_steps; i++)) do
    updater="$updaters[i]"
    flog_log "${__flog_color_standout}Update ${${updater#*__*_*}//_/ }${__flog_color_normal} ($i of $total_steps)"
    if flog_confirm "Proceed?"; then
      flog_indent 2
      "$updater"
      flog_indent -2
    fi
  done
}
