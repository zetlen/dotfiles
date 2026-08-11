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

# Glob instead of forking find+sort twice on every startup: glob expansion is
# already lexically sorted in both bash and zsh. Wrapped in a function only so
# the nullglob setting can be scoped; the sourcing itself happens at the
# caller's level via the list this builds.
__common_ext_files() {
    if [ -n "${ZSH_VERSION:-}" ]; then
        setopt local_options null_glob
    else
        local restore_nullglob
        shopt -q nullglob || restore_nullglob=1
        shopt -s nullglob
    fi
    __COMMON_EXT_FILES=("$DOTFILE_PATH"/lib/common/*."$1"*)
    [ -z "${restore_nullglob:-}" ] || shopt -u nullglob
}

# only import the *.sh version if there isn't one for the current shell
__common_ext_files sh
for file in "${__COMMON_EXT_FILES[@]}"; do
    [ -f "${file%.sh}"".$CURRENT_SHELL" ] || . "$file"
done

# then the scripts written for the current shell
__common_ext_files "$CURRENT_SHELL"
for file in "${__COMMON_EXT_FILES[@]}"; do
    . "$file"
done

unset -f __common_ext_files
unset __COMMON_EXT_FILES file
