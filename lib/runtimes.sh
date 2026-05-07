setup_runtimes() {
    [ -z "${__DOTFILES_RUNTIMES_LOADED:-}" ] || return 0

    _dotfiles_mise_bin="${HOME}/.local/bin/mise"
    [ -x "$_dotfiles_mise_bin" ] || return 0

    __DOTFILES_RUNTIMES_LOADED=1

    if [ -n "${ZSH_VERSION:-}" ]; then
        _dotfiles_mise_shell="zsh"
    elif [ -n "${BASH_VERSION:-}" ]; then
        _dotfiles_mise_shell="bash"
    else
        _dotfiles_mise_shell=""
    fi

    if [ -n "$_dotfiles_mise_shell" ]; then
        eval "$("$_dotfiles_mise_bin" activate "$_dotfiles_mise_shell")"
    else
        case ":${PATH:-}:" in
        :"$HOME/.local/bin":*) ;;
        *) PATH="$HOME/.local/bin${PATH:+:$PATH}" ;;
        esac
        case ":${PATH:-}:" in
        :"$HOME/.local/share/mise/shims":*) ;;
        *) PATH="$HOME/.local/share/mise/shims${PATH:+:$PATH}" ;;
        esac
        export PATH
    fi

    unset _dotfiles_mise_bin _dotfiles_mise_shell
}

setup_runtimes
