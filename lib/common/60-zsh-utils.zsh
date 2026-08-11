# Dedupe PATH on every assignment, the same way fpath is handled. Keeps the
# first occurrence, so precedence is unchanged.
typeset -gU path PATH

# `<tool> init zsh` costs 40-50ms of process startup each and its output rarely
# changes, so cache the text and source that instead. Caches live outside the
# repo and can be deleted at any time.
ZSH_INIT_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init"

# Refresh half of cached_shell_init: guarantees a fresh, zcompiled cache file
# at $1, or returns 1 when the tool emitted nothing. Runs nothing from the
# cache itself, so emulate -L is safe here.
__cached_shell_init_refresh() {
    emulate -L zsh
    local cache=$1 header have= body tmp
    shift
    # The first line of the cache records the exact command line that built it,
    # so editing a call site (say, an atuin flag) rebuilds the cache instead of
    # silently reusing it.
    header="# built by cached_shell_init from: ${(j: :)${(q)@}}"
    [[ -s $cache ]] && IFS= read -r have < $cache
    # A mise shim keeps the same mtime across tool upgrades, so the mtime check
    # cannot catch every stale cache. zsh-init-cache-clear, which zsh-update-all
    # runs, is the reliable invalidation.
    if [[ $have != "$header" || $commands[$1] -nt $cache ]]; then
        body=$("$@" 2>/dev/null)
        [[ -n $body ]] || return 1
        mkdir -p $ZSH_INIT_CACHE_DIR
        tmp=$cache.$$
        if ! print -r -- $header$'\n'$body >| $tmp || ! mv -f $tmp $cache; then
            rm -f $tmp
            return 1
        fi
    fi
    [[ -e $cache.zwc && ! $cache -nt $cache.zwc ]] || zcompile -R $cache.zwc $cache 2>/dev/null
}

# usage: cached_shell_init <cache-name> <command> [args...]
# Deliberately NOT under emulate -L, and no locals: init scripts change global
# shell state (starship runs `setopt promptsubst`), and LOCAL_OPTIONS would
# revert every setopt when this returns, leaving PROMPT as the literal text
# "$(starship prompt ...)". Covered by test/zshrc-init.test.zsh.
cached_shell_init() {
    # Missing tool is a skip, not an error: call sites treat these
    # integrations as optional, and .zshrc ends with one, so a nonzero return
    # here would surface as a failed command in the first prompt.
    (( $+commands[$2] )) || return 0
    if __cached_shell_init_refresh "$ZSH_INIT_CACHE_DIR/$1.zsh" "${@[2,-1]}"; then
        source "$ZSH_INIT_CACHE_DIR/$1.zsh"
    else
        # tool declined to emit an init script; fall back to the live call
        eval "$("${@[2,-1]}" 2>/dev/null)"
    fi
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
