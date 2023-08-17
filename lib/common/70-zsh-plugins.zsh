ZPLUGINDIR="${HOME}/.config/zsh/plugins/"
ZPLUGIN_UPDATE_SENTINEL="${HOME}/.config/zsh/.zsh-plugins-updated"

function zsh-plugin-init {
  if [[ ! -d "$ZPLUGINDIR" ]]; then
    flog_confirm "$ZPLUGINDIR does not exist. Create?"
    mkdir -p "$ZPLUGINDIR"
  fi
  if zsh -c "ls ${ZPLUGIN_UPDATE_SENTINEL}(Dmd+30)" &>/dev/null; then
		flog_warn "It has been more than 30 days since updating your plugins. Run zsh-plugin-update to update them."
	fi
}

# clone a plugin, identify its init file, source it, and add it to your fpath
function zsh-plugin-load {
  local repo plugin_name plugin_dir initfile initfiles
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
	repo="$1"
	plugin_name=${repo:t}
	plugin_dir=${ZPLUGINDIR}${plugin_name}
	initfile=$plugin_dir/$plugin_name.plugin.zsh
	if [[ ! -d $plugin_dir ]]; then
		repo_url="https://github.com/$repo"
		flog_log "Downloading zsh plugin at $repo_url"
		repo_req_status="$(curl -sfo /dev/null -w '%{http_code} %{errormsg}' $repo_url)"
		if [[ $? -eq 0 ]]; then
			git clone -q --depth 1 --recursive --shallow-submodules $repo_url $plugin_dir
		else
			flog_error "Could not download $repo_url: $repo_req_status"
			return 1
		fi
	fi
	if [[ ! -e $initfile ]]; then
		initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
		[[ ${#initfiles[@]} -gt 0 ]] || { flog_error >&2 "Plugin has no init file '$repo'." && continue }
		ln -sf "${initfiles[1]}" "$initfile"
	fi
	fpath+=$plugin_dir
	(( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
}

function zsh-plugin-update {
	for d in $ZPLUGINDIR/*/.git(/); do
		flog_log "Updating ${d:h:t}..."
		command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
	done
	touch "$ZPLUGIN_UPDATE_SENTINEL"
}
