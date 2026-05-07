__set_node_aliases() {

    alias y='yarn '
    alias yr='yarn run '
    alias p='pnpm '
    alias pr='pnpm run '
    alias prr='pnpm run -r '
    alias prip='pnpm run -r --if-present '
    alias prf='pnpm run --filter '
    alias pripf='pnpm run --if-present --filter '
    alias b='bun '
    alias br='bun run'

    _pm='npm'
    __notice=''

    alias n='echo -n $__notice && $_pm '
    alias nr="n run"

    ni() {
        if [ -z "$1" ]; then
            $_pm install
        else
            $_pm add "$@"
        fi
    }

    if [ -n "$(find_up yarn.lock)" ]; then
        __notice="yarn.lock detected, aliasing npm to yarn\n"
        _pm='yarn'
    elif [ -n "$(find_up pnpm-lock.yaml)" ]; then
        __notice="pnpm-lock.yaml detected, aliasing npm to pnpm\n"
        _pm='pnpm'
    elif [ -n "$(find_up bun.lock)" ]; then
        __notice="bun.lock detected, aliasing npm to bun\n"
        _pm='bun'
    fi

    clean_project() {
        $_pm run --if-present clean && in_repo && git wash
        return 0
    }
    alias delete_node_modules='find . -name "node_modules" -type d -prune -exec rm -rf '{}' +'
    alias nenv='printf "node %s\n%s %s\n" "$(node -v)" $_pm "$($_pm --version)"'
    alias nreset='clean_project; delete_node_modules; ni;'
}

add_cd_hook __set_node_aliases
