get_os_id() {
    KERNEL_ID="$(uname)"
    if [[ "$KERNEL_ID" == "Linux" && -e /etc/os-release ]]; then
        . /etc/os-release
        echo "$KERNEL_ID/$ID"
    else
        echo "$KERNEL_ID"
    fi
}

get_os_dotfile_path() {
    local osid="$(get_os_id)"
    local osidpath="$DOTFILE_PATH/os/$osid"
    if [ ! -d "$osidpath" ]; then
        osid="$(dirname "$osid")"
        osidpath="$DOTFILE_PATH/os/$osid/generic"
        if [ ! -d "$osidpath" ]; then
            osidpath="$DOTFILE_PATH/os/generic"
        fi
    fi
    echo $osidpath
}

add_os_rc() {
    THE_SHELL="$1"
    # fail silently if it doesn't exist
    . "$(get_os_dotfile_path)/.${THE_SHELL}rc" 2>/dev/null || true
}
