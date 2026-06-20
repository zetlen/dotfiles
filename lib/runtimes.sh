setup_runtimes() {
    [ -z "${__DOTFILES_RUNTIMES_LOADED:-}" ] || return 0

    _dotfiles_mise_bin="${HOME}/.local/bin/mise"
    [ -x "$_dotfiles_mise_bin" ] || return 0

    # Exported so it survives into non-interactive child shells. BASH_ENV
    # makes every command substitution source this file; without the export
    # the guard above always reads empty in children and re-runs activation,
    # which recurses into a fork bomb.
    export __DOTFILES_RUNTIMES_LOADED=1

    if [ -n "${ZSH_VERSION:-}" ]; then
        _dotfiles_mise_shell="zsh"
    elif [ -n "${BASH_VERSION:-}" ]; then
        _dotfiles_mise_shell="bash"
    else
        _dotfiles_mise_shell=""
    fi

    # Detect interactivity: $- contains 'i' only in interactive shells.
    case $- in
    *i*) _dotfiles_interactive=1 ;;
    *) _dotfiles_interactive="" ;;
    esac

    if [ -n "$_dotfiles_mise_shell" ] && [ -n "$_dotfiles_interactive" ]; then
        # Interactive shell: full activation (per-prompt version switching,
        # prompt hooks, mise() wrapper). Only safe interactively.
        eval "$("$_dotfiles_mise_bin" activate "$_dotfiles_mise_shell")"
    else
        # Non-interactive shell (scripts, command substitutions) or unknown
        # shell: static shims on PATH only. No functions, no hooks, no
        # subprocess spawning -- so no recursion surface. Tools still resolve
        # project-local versions via the shim's config walk.
        case ":${PATH:-}:" in
        *:"$HOME/.local/bin":*) ;;
        *) PATH="$HOME/.local/bin${PATH:+:$PATH}" ;;
        esac
        case ":${PATH:-}:" in
        *:"$HOME/.local/share/mise/shims":*) ;;
        *) PATH="$HOME/.local/share/mise/shims${PATH:+:$PATH}" ;;
        esac
        export PATH
    fi

    unset _dotfiles_mise_bin _dotfiles_mise_shell _dotfiles_interactive
}

setup_runtimes
