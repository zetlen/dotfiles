# Memoized: every caller wrapped this in $(...), so a plain interactive
# startup forked `uname` and its subshells several times over.
get_os_id() {
    if [ -z "${__DOTFILES_OS_ID:-}" ]; then
        local kernel_id
        kernel_id="$(uname)"
        if [ "$kernel_id" = "Linux" ] && [ -e /etc/os-release ]; then
            # subshell keeps os-release's ID/NAME/VERSION out of the caller
            __DOTFILES_OS_ID="$kernel_id/$(. /etc/os-release && printf '%s' "$ID")"
        else
            __DOTFILES_OS_ID="$kernel_id"
        fi
    fi
    echo "$__DOTFILES_OS_ID"
}

get_os_dotfile_path() {
    if [ -n "${__DOTFILES_OS_PATH:-}" ]; then
        echo "$__DOTFILES_OS_PATH"
        return 0
    fi
    local osid="$(get_os_id)"
    local osidpath="$DOTFILE_PATH/os/$osid"
    if [ ! -d "$osidpath" ]; then
        osid="$(dirname "$osid")"
        osidpath="$DOTFILE_PATH/os/$osid/generic"
        if [ ! -d "$osidpath" ]; then
            osidpath="$DOTFILE_PATH/os/generic"
        fi
    fi
    __DOTFILES_OS_PATH="$osidpath"
    echo "$osidpath"
}

add_os_rc() {
    local the_shell="$1"
    # no $(...) here: get_os_dotfile_path memoizes into __DOTFILES_OS_PATH,
    # and a subshell would throw that away on every startup
    get_os_dotfile_path >/dev/null
    # fail silently if it doesn't exist
    . "${__DOTFILES_OS_PATH}/.${the_shell}rc" 2>/dev/null || true
}

# Detect Homebrew prefix once instead of forking `brew --prefix` per shell.
# Set early so skel/.bashrc bash-completion lookups can use it before the
# OS-specific rc file runs.
get_os_id >/dev/null
case "$__DOTFILES_OS_ID" in
Darwin*)
    if [ -x /opt/homebrew/bin/brew ]; then
        __HOMEBREW_PREFIX=/opt/homebrew
    elif [ -x /usr/local/bin/brew ]; then
        __HOMEBREW_PREFIX=/usr/local
    fi
    ;;
esac
