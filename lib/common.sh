# shellcheck disable=SC1090,SC1091
# tell shellcheck to quit complaining about dynamic paths

DOTFILE_PATH="${DOTFILE_PATH:-$HOME/.dotfiles}"

if [ -n "${ZSH_VERSION:-}" ]; then
    CURRENT_SHELL="zsh"
elif [ -n "${BASH_VERSION:-}" ]; then
    CURRENT_SHELL="bash"
else
    return 0 2>/dev/null || exit 0
fi

. "$DOTFILE_PATH/lib/logging.sh"

add_cd_hook() {
    case "$CURRENT_SHELL" in
    zsh)
        autoload -Uz add-zsh-hook
        add-zsh-hook chpwd "$1"
        "$1"
        ;;
    *)
        case "${PROMPT_COMMAND:-}" in
        *"$1"*) ;;
        "") PROMPT_COMMAND="$1" ;;
        *) PROMPT_COMMAND="${PROMPT_COMMAND};${1}" ;;
        esac
        "$1"
        ;;
    esac
}

# glob without breaking in any shell
ext_matches() {
    find "$DOTFILE_PATH"/lib/common -maxdepth 1 -name "*.${1}*" -print | sort
}

# iterate through newline-delimited .sh files
while read -r file; do
    # only import *.sh version if there isn't one for the current shell
    [ -f "${file%.sh}"".$CURRENT_SHELL" ] || . "$file"
done < <(ext_matches sh)

# iterate through newline-delimited scripts for the current shell
while read -r file; do
    . "$file"
done < <(ext_matches "$CURRENT_SHELL")
