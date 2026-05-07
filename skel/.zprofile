# .zshenv has already sourced .profile and runtimes.sh; nothing more needed
# unless macOS /etc/zprofile ran path_helper between then and now, in which
# case PATH ordering needs to be re-established so mise shims win.
[ -x /usr/libexec/path_helper ] \
    && command -v __dotfiles_setup_path >/dev/null 2>&1 \
    && __dotfiles_setup_path
