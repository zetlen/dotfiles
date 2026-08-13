OSNAME="$(get_os_id)"
OSPATH="$(get_os_dotfile_path)"

die_bc() {
    flog_error "Cannot proceed! $*"
    exit 1
}

confirm_cmd() {
    fmted="$(printf 'Run %s%s%s ?' "$__flog_startul" "$*" "$__flog_endul")"
    flog_confirm "$fmted" && eval "$*"
}

link_or_warn() {
    # $1 src_path, $2 tgt_path, $3 display name
    if ln -s "$1" "$2"; then
        flog_success "Symlinked $3 to $1"
    else
        flog_error "Failed to symlink $2 to $1"
        return 1
    fi
}

# merge_json_fragments <live_file> <fragment>...
#
# Deep-merges fragments over a live, app-owned JSON file, in argument order.
# Used for ~/.claude/settings.json, which can be neither symlinked nor
# `include`d: Claude Code rewrites it in place and its schema has no include
# directive, so the repo owns fragments and the installer merges them.
#
# jq's `*` merges objects RECURSIVELY but replaces arrays WHOLESALE, and both
# halves are load-bearing: enabledPlugins is an object, so pinning a few
# plugins leaves the host's other choices alone, while permissions.ask is an
# array the repo therefore owns outright. A key no fragment declares is left
# exactly as the app wrote it.
#
# Writes through a temp file so a jq failure leaves the live file intact.
merge_json_fragments() {
    local live="$1"
    shift
    if [ "$#" -eq 0 ]; then
        flog_error "merge_json_fragments: no fragments given for $live"
        return 1
    fi
    if [ ! -s "$live" ]; then
        echo '{}' >"$live" || return 1
    fi
    if jq -s 'reduce .[] as $frag ({}; . * $frag)' "$live" "$@" >"${live}.tmp"; then
        mv "${live}.tmp" "$live"
    else
        rm -f "${live}.tmp"
        flog_error "jq failed to merge fragments; $live left untouched."
        return 1
    fi
}

sync_links_from_dir() {
    local src_dir="$1"
    local f src_path tgt_path tgt_dir tgt_orig tgt_old_path
    local files=()
    while IFS= read -r f; do
        files+=("${f#./}")
    done < <(cd "$src_dir" && find . -type f)
    for f in "${files[@]}"; do
        src_path="$(normalize_dir "$src_dir" "$f")"
        tgt_path="$(normalize_dir "$HOME" "$f")"
        tgt_dir="$(dirname "$tgt_path")"
        if [ ! -d "$tgt_dir" ]; then
            flog_log "Creating directory $tgt_dir"
            mkdir -p "$tgt_dir"
        fi
        if [ -L "$tgt_path" ]; then
            tgt_orig="$(readlink "$tgt_path")"
            tgt_orig="$(normalize_dir "$tgt_orig")"
            if [ "$tgt_orig" = "$src_path" ]; then
                flog_log "$f is already symlinked to $src_path"
            elif [ "${tgt_orig#$DOTFILE_PATH}" = "$tgt_orig" ]; then
                flog_warn "$f is already symlinked to ${tgt_orig}."
                flog_warn "Not symlinking $src_path because $f is already symlinked to $tgt_orig."
            else
                flog_log "Updating symlink of $f to $src_path"
                rm "$tgt_path"
                link_or_warn "$src_path" "$tgt_path" "$f"
            fi
        elif [ -d "$tgt_path" ]; then
            # never fall through to `ln -s` here: it would silently create the
            # link *inside* this directory and report success
            flog_warn "A directory already exists at $tgt_path."
            flog_warn "Not symlinking $f. Move or remove $tgt_path, then run this again."
        elif [ -e "$tgt_path" ]; then
            flog_warn "A file already exists at $tgt_path."
            if flog_confirm "Replace with symlink to ${src_path}?"; then
                tgt_old_path="${tgt_path}.local"
                if [ -e "$tgt_old_path" ]; then
                    flog_warn "$tgt_old_path exists as well! Move or remove it first."
                else
                    mv "$tgt_path" "$tgt_old_path"
                    flog_success "Moved old $tgt_path to $tgt_old_path"
                    link_or_warn "$src_path" "$tgt_path" "$f"
                fi
            fi
        else
            link_or_warn "$src_path" "$tgt_path" "$f"
        fi
    done
}
