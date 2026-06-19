export ZDOTDIR="${ZDOTDIR:-$HOME}"
export DOTFILE_PATH="${DOTFILE_PATH:-$HOME/.dotfiles}"

# Defined unconditionally so .zprofile can re-call it after macOS path_helper
# runs in /etc/zprofile and reorders PATH.
__dotfiles_setup_path() {
    _dotfiles_path_remove() {
        case ":${PATH:-}:" in
        *:"$1":*) ;;
        *) return 0 ;;
        esac
        _dotfiles_t=":${PATH}:"
        _dotfiles_after="${_dotfiles_t#*:$1:}"
        _dotfiles_before="${_dotfiles_t%"$_dotfiles_after"}"
        _dotfiles_before="${_dotfiles_before%:$1:}"
        _dotfiles_t="${_dotfiles_before}:${_dotfiles_after}"
        _dotfiles_t="${_dotfiles_t#:}"
        PATH="${_dotfiles_t%:}"
    }

    _dotfiles_path_append() {
        [ -n "$1" ] || return 0
        [ "${1#/}" != "$1" ] || return 0
        case ":${PATH:-}:" in
        *:"$1":*) ;;
        *) PATH="${PATH:+$PATH:}$1" ;;
        esac
    }

    _dotfiles_path_prepend() {
        [ -n "$1" ] || return 0
        [ "${1#/}" != "$1" ] || return 0
        case ":${PATH:-}:" in
        :"$1":*) return 0 ;;
        esac
        _dotfiles_path_remove "$1"
        PATH="$1${PATH:+:$PATH}"
    }

    # Prepend in reverse priority: last prepended ends up first in PATH.
    # Final user-dir order: $HOME/bin, $HOME/.local/bin, $HOME/.cargo/bin, ...
    _dotfiles_path_prepend "$HOME/.config/yarn/global/node_modules/.bin"
    _dotfiles_path_prepend "$HOME/.local/share/pnpm"
    _dotfiles_path_prepend "$HOME/.yarn/bin"
    _dotfiles_path_prepend "$HOME/Library/Python/3.9/bin"
    _dotfiles_path_prepend "$HOME/.rvm/bin"
    _dotfiles_path_prepend "$HOME/.composer/vendor/bin"
    _dotfiles_path_prepend "$HOME/.cargo/bin"
    _dotfiles_path_prepend "$HOME/.local/bin"
    _dotfiles_path_prepend "$HOME/bin"

    # Homebrew must beat /usr/bin (Apple ships openrsync etc. there), and
    # nothing else guarantees that outside interactive shells: brew shellenv
    # only runs in .zshrc, and macOS path_helper demotes Homebrew on every
    # login shell init. Prepend here, before mise, so mise still wins.
    if [ -x /opt/homebrew/bin/brew ]; then
        _dotfiles_path_prepend "/opt/homebrew/sbin"
        _dotfiles_path_prepend "/opt/homebrew/bin"
    elif [ -x /usr/local/bin/brew ]; then
        _dotfiles_path_prepend "/usr/local/sbin"
        _dotfiles_path_prepend "/usr/local/bin"
    fi

    if [ -x "$HOME/.local/bin/mise" ]; then
        _dotfiles_path_prepend "$HOME/.local/bin"
        _dotfiles_path_prepend "$HOME/.local/share/mise/shims"
    fi

    export PATH

    unset _dotfiles_t _dotfiles_after _dotfiles_before 2>/dev/null
    unset -f _dotfiles_path_append _dotfiles_path_prepend _dotfiles_path_remove 2>/dev/null
    return 0
}

if [ -z "${__DOTFILES_PROFILE_LOADED:-}" ]; then
    __DOTFILES_PROFILE_LOADED=1
    export __DOTFILES_PROFILE_LOADED

    export LANG="${LANG:-en_US.UTF-8}"
    export LANGUAGE="${LANGUAGE:-$LANG}"
    export LC_ALL="${LC_ALL:-$LANG}"
    export LC_CTYPE="${LC_CTYPE:-$LANG}"

    export SVN_EDITOR="${SVN_EDITOR:-vim}"
    export EDITOR="${EDITOR:-vim}"
    export PAGER="${PAGER:-less -R}"
    export BAT_THEME="${BAT_THEME:-ansi}"

    __dotfiles_setup_path

    if [ -z "${BASH_ENV:-}" ]; then
        if [ -r "$HOME/.bash_env" ]; then
            BASH_ENV="$HOME/.bash_env"
        elif [ -r "$DOTFILE_PATH/skel/.bash_env" ]; then
            BASH_ENV="$DOTFILE_PATH/skel/.bash_env"
        else
            BASH_ENV="$HOME/.bash_env"
        fi
        export BASH_ENV
    fi

    # Machine-local POSIX overrides (sensitive env exports, etc.). Kept out of
    # the repo like .zshrc.local, but sourced here so the exports reach every
    # shell -- interactive or not, zsh or bash -- and inherit into children.
    # POSIX sh only: this runs under dash/sh, so no bashisms or zsh syntax.
    if [ -r "$HOME/.profile.local" ]; then
        . "$HOME/.profile.local"
    fi
fi
