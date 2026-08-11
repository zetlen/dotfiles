# `<tool> init zsh` costs 40-50ms of process startup each and its output rarely
# changes, so cache the text and source that instead. Caches live outside the
# repo and can be deleted at any time.
ZSH_INIT_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init"

# usage: cached_shell_init <cache-name> <command> [args...]
cached_shell_init() {
    emulate -L zsh
    local name=$1 tool=$2 cache tmp
    shift
    (( $+commands[$tool] )) || return 1
    cache="$ZSH_INIT_CACHE_DIR/$name.zsh"
    # A mise shim keeps the same mtime across tool upgrades, so this check
    # cannot catch every stale cache. zsh-init-cache-clear, which zsh-update-all
    # runs, is the reliable invalidation.
    if [[ ! -s $cache || $commands[$tool] -nt $cache ]]; then
        mkdir -p $ZSH_INIT_CACHE_DIR
        tmp=$cache.$$
        if "$@" >| $tmp 2>/dev/null && [[ -s $tmp ]]; then
            mv -f $tmp $cache
        else
            # tool declined to emit an init script; fall back to the live call
            rm -f $tmp
            eval "$("$@" 2>/dev/null)"
            return
        fi
    fi
    [[ -e $cache.zwc && ! $cache -nt $cache.zwc ]] || zcompile -R $cache.zwc $cache 2>/dev/null
    source $cache
}

zsh-init-cache-clear() {
    emulate -L zsh
    rm -rf "$ZSH_INIT_CACHE_DIR"
    flog_log "Cleared shell init cache; the next new shell will rebuild it."
}

zsh_show_all_completions() {
    for completion in ${(@k)_comps:#-*(-|-,*)}; do
        printf "%-20s %s\n" $completion "$(command -V $_comps[$completion])"
    done | sort
}
