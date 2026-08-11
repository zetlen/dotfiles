# keep fpath unique on every assignment, so repeated plugin loads can't grow it
typeset -gU fpath

ZPLUGINDIR="${HOME}/.config/zsh/plugins"
ZPLUGIN_UPDATE_SENTINEL="${HOME}/.config/zsh/.zsh-plugins-updated"

function zsh-plugin-init {
    emulate -L zsh
    local -a stale
    if [[ ! -d "$ZPLUGINDIR" ]]; then
        flog_confirm "$ZPLUGINDIR does not exist. Create?" || return 1
        mkdir -p "$ZPLUGINDIR"
    fi
    # start the clock now, so the reminder can actually fire for someone who
    # has never run zsh-plugin-update
    [[ -e "$ZPLUGIN_UPDATE_SENTINEL" ]] || touch "$ZPLUGIN_UPDATE_SENTINEL"
    # glob qualifiers resolve in-process; forking `zsh -c` to do this cost
    # ~180ms of every interactive shell startup
    stale=( ${ZPLUGIN_UPDATE_SENTINEL}(Dmd+30N) )
    if (( $#stale )); then
        flog_warn "It has been more than 30 days since updating your plugins. Run zsh-plugin-update to update them."
    fi
}

# clone a plugin, identify its init file, source it, and add it to your fpath
function zsh-plugin-load {
    local initfile
    # the setup runs in an anonymous function so `emulate -L zsh` can guard our
    # option assumptions without also reverting the setopts a plugin performs
    # when it is sourced below
    () {
        emulate -L zsh
        local repo=$1 plugin_name plugin_dir
        local -a initfiles
        : ${ZPLUGINDIR:=${ZDOTDIR:-$HOME/.config/zsh}/plugins}
        plugin_name=${repo:t}
        plugin_dir=${ZPLUGINDIR%/}/${plugin_name}
        initfile=$plugin_dir/$plugin_name.plugin.zsh
        if [[ ! -d $plugin_dir ]]; then
            echo "Cloning $repo"
            if ! git clone -q --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir; then
                echo >&2 "Failed to clone '$repo'."
                rm -rf $plugin_dir
                return 1
            fi
        fi
        if [[ ! -e $initfile ]]; then
            # (-.) so a directory named like an init file can't be picked
            initfiles=($plugin_dir/*.plugin.{z,}sh(N-.) $plugin_dir/*.{z,}sh{-theme,}(N-.))
            if (( $#initfiles == 0 )); then
                echo >&2 "Plugin has no init file '$repo'."
                return 1
            fi
            ln -sf "${initfiles[1]}" "$initfile"
        fi
        # `source f` picks up f.zwc when it is the newer of the two, skipping
        # the parse; a stale .zwc is ignored, not wrongly used. Compile the
        # whole top level, not just $initfile, because the entry file is
        # usually a thin wrapper that sources the bulk of the plugin at
        # runtime -- that inner source wants a .zwc too. Deliberately not
        # recursive: `**/` over every plugin dir costs ~12ms per startup,
        # more than the compilation saves.
        local src
        for src in $initfile $plugin_dir/*.{z,}sh(N-.); do
            [[ -e $src.zwc && ! $src -nt $src.zwc ]] && continue
            # best effort: a read-only plugin dir costs speed, not correctness
            zcompile -R $src.zwc $src 2>/dev/null
        done
        return 0
    } "$1" || return 1
    fpath+=${initfile:h}
    if (( $+functions[zsh-defer] )); then
        zsh-defer . $initfile
    else
        . $initfile
    fi
}

function zsh-plugin-update {
    emulate -L zsh
    local d
    for d in ${ZPLUGINDIR%/}/*/.git(N/); do
        echo "Updating ${d:h:t}..."
        command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
    done
    touch "$ZPLUGIN_UPDATE_SENTINEL"
}
