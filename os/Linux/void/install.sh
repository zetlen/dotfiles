__TO_INSTALL=(
    base-devel
    bzip2-devel
    cmake
    curl
    fzf
    git
    gnupg2
    jq
    libffi-devel
    liblzma-devel
    libxml2-devel
    libxml++-devel
    llvm
    lsof
    ncurses-devel
    openssl-devel
    readline-devel
    ripgrep
    sqlite-devel
    unzip
    vim
    wget
    zsh
)

__pkg_is_available() {
    xbps-query -R "$1" &> /dev/null
}

__pkg_install_all() {
    sudo chmod a=rwx,u+t /tmp
    sudo xbps-install -Su && sudo xbps-install -Su
    __INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
    test -n "$__INSTALLABLE" && confirm_cmd "sudo xbps-install -y $__INSTALLABLE"
}

__pkg_update_all() {
    sudo xbps-install -Su
}
