setup_runtimes() {

    local mise_bin_loc="${HOME}/.local/bin/mise"
    [ -x "$mise_bin_loc" ] \
                         && eval "$($mise_bin_loc activate)" \
                                     && eval "$($mise_bin_loc hook-env)"
}

setup_runtimes
