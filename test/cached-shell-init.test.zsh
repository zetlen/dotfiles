#!/usr/bin/env zsh
# Unit tests for cached_shell_init, run in zsh -f with an isolated cache dir
# so the real ~/.cache is untouched.

repo=${0:a:h:h}
work=$(mktemp -d) || exit 1
trap 'rm -rf "$work"' EXIT

fail=0
check() {
    local name=$1 script=$2 result
    result=$(zsh -f -c "
        source $repo/lib/common/60-zsh-utils.zsh
        ZSH_INIT_CACHE_DIR=$work/cache-\$\$
        $script
    ")
    if [[ $result == PASS ]]; then
        print "ok   $name"
    else
        print "FAIL $name ($result)"
        fail=1
    fi
}

# The cache file is keyed by <cache-name> alone; if the generating command
# line changes (e.g. dropping --disable-up-arrow from the atuin call in
# .zshrc), the cache must be rebuilt, not silently reused.
check "changed command line rebuilds the cache" '
    cached_shell_init t printf "FIRST=%s" 1
    cached_shell_init t printf "SECOND=%s" 2
    [[ ${SECOND:-unset} == 2 ]] && print PASS || print "second=${SECOND:-unset}"
'

# Call sites treat these tool integrations as optional, and .zshrc ends with
# one: if the missing-tool case returned nonzero, the first prompt on any
# machine without that tool would report a failed command.
check "missing tool is a skip, not an error" '
    cached_shell_init t definitely-not-a-command init zsh
    rc=$?
    [[ $rc == 0 ]] && print PASS || print "rc=$rc"
'

exit $fail
