__TO_INSTALL=(
    build-essential
    curl
    git
    gnupg2
    libbz2-dev
    libffi-dev
    liblzma-dev
    libncursesw5-dev
    libreadline-dev
    libsqlite3-dev
    libssl-dev
    libxml2-dev
    libxmlsec1-dev
    lsof
    tk-dev
    unzip
    wget
    xz-utils
    zlib1g-dev
    zsh
)

__pkg_is_available() {
    local to_check="$1"
    local apt_search_exp="$(printf '^%s$' "$to_check")"
    test -n "$(apt-cache search --names-only "$apt_search_exp")"
}
__pkg_install_all() {
    sudo locale-gen "en_US.UTF-8"
    sudo apt update
    __INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
    test -n "$__INSTALLABLE" && confirm_cmd "sudo apt install -y $__INSTALLABLE"
}

__pkg_update_all() {
    sudo apt update && sudo apt dist-upgrade
}
