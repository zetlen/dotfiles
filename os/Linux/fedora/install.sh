__TO_INSTALL=(
    curl
    g++
    git
    gnupg2
    lsof
    tar
    unzip
    vim-common
    vim-enhanced
    wget
    zsh
)

__pkg_is_installed() {
    dnf list --installed "$1" &>/dev/null
}

__pkg_is_available() {
    dnf info "$1" &>/dev/null
}

__pkg_install_all() {
    __INSTALLABLE="$(__pkg_get_installable ${__TO_INSTALL[@]})"
    test -n "$__INSTALLABLE" && confirm_cmd "sudo dnf install -y $__INSTALLABLE"
    sudo dnf groupinstall "Development Tools" "Development Libraries"
}

__pkg_update_all() {
    sudo dnf upgrade
}
