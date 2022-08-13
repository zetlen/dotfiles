#!/usr/bin/env zsh

. "${HOME}/.dotfiles/lib/logging.sh"

ZPLUGINDIR="${HOME}/.config/zsh/plugins/"

function zsh-plugin-init {
  if [[ ! -d "$ZPLUGINDIR" ]]; then
    flog_confirm "$ZPLUGINDIR does not exist. Create?"
    mkdir -p "$ZPLUGINDIR"
  fi
	updated_sentinel="${HOME}/.config/zsh/.zsh-plugins-updated"
	[ -f "$updated_sentinel" ] || touch "$updated_sentinel"
	time_since="$(perl -l -e '$modi = -M $ARGV[0]; printf("%.0f\n", $modi)' "$updated_sentinel")"
	if (( time_since > 30 )) && flog_confirm "It has been ${time_since} days since updating your plugins. Update them now?"; then
		zsh-plugin-update
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
		echo "Cloning $repo"
		git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir
	fi
	if [[ ! -e $initfile ]]; then
		initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
		[[ ${#initfiles[@]} -gt 0 ]] || { echo >&2 "Plugin has no init file '$repo'." && continue }
		ln -sf "${initfiles[1]}" "$initfile"
	fi
	fpath+=$plugin_dir
	(( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
}

function zsh-plugin-update {
	for d in $ZPLUGINDIR/*/.git(/); do
		echo "Updating ${d:h:t}..."
		command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
	done
	touch "$updated_sentinel"
}
