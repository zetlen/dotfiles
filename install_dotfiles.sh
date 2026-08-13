#!/bin/bash
# shellcheck disable=SC2059,SC2034

. "$HOME/.dotfiles/skel/.profile"
. "$HOME/.dotfiles/lib/common.sh"
. "$HOME/.dotfiles/lib/installing.sh"

if [ ! -d "$OSPATH" ]; then
    die_bc "Unknown OS '${OSNAME}'. Gotta install everything manually."
fi

__pkg_is_installed() {
    i_have "$1"
}

__pkg_is_available() {
    false
}

__pkg_install_all() {
    flog_warn "Could not detect what package manager to use. The following commands are expected in PATH:"
    __pkg_get_installable
    flog_warn "Install may fail without missing packages."
}

declare -a installed_pkgs
declare -a unavailable_pkgs
declare -a to_install

__pkg_get_installable() {
    installed_pkgs=()
    unavailable_pkgs=()
    to_install=()
    flog_log "Checking for packages: $*"
    for pkg in "$@"; do
        if i_dont_have "$pkg" && ! __pkg_is_installed "$pkg"; then
            if __pkg_is_available "$pkg"; then
                to_install+=("$pkg")
            else
                unavailable_pkgs+=("$pkg")
            fi
        else
            installed_pkgs+=("$pkg")
        fi
    done
    if ((${#installed_pkgs[@]})); then
        flog_success "Already installed: ${installed_pkgs[*]}"
    fi
    if ((${#unavailable_pkgs[@]})); then
        flog_error "Package manager doesn't have: ${unavailable_pkgs[*]}"
    fi
    if ((${#to_install[@]})); then
        flog_log "To install: ${to_install[*]}"
        echo "${to_install[*]}"
    else
        flog_success "Nothing to install, everything's here."
    fi
}

if REPO_PATH=$(git rev-parse --show-toplevel); then
    TAGFMT="-wip-$(date '+%H%M%Z')"
    flog_log "Installing zetlen dotfiles version" "${__flog_standouton}$(git describe --dirty="$TAGFMT" --tags --always)${__flog_standoutoff}"
else
    die_bc "This script must be run from the root of the zetlen/dotfiles Git repository, but no Git repository was detected."
fi

run_dotfile_steps() {

    __zdi_step_10__verifying_paths() {
        if [ "$REPO_PATH" != "$DOTFILE_PATH" ]; then
            die_bc "This repo is located in the directory ${REPO_PATH}, but it only works if it is checked out in ${DOTFILE_PATH}."
        fi
        flog_success "Repo path is $REPO_PATH"
        if [ "$(pwd)" != "$REPO_PATH" ]; then
            die_bc "Current directory is $(pwd). This script must be executed from its own directory, which is ${REPO_PATH}."
            return 1
        fi
        flog_success "Current directory is repo root"
    }

    __zdi_step_20__installing_system_packages() {
        flog_log "Finding package install routing for $OSNAME..."
        if [ ! -e "${OSPATH}/install.sh" ]; then
            flog_warn "No install script for OS "$OSNAME" present."
        else
            . "${OSPATH}/install.sh" || die_bc "Error running install script ${OSPATH}/install.sh"
            flog_success "Found ${OSPATH}/install.sh"
            __pkg_install_all
        fi
    }

    __zdi_step_30__linking_to_homedir() {
        flog_indent 1
        sync_links_from_dir "${DOTFILE_PATH}/skel"
        flog_indent 1
        [ -d "${OSPATH}/skel" ] && flog_log "Installing dotfiles specific to ${OSNAME}..." && sync_links_from_dir "${OSPATH}/skel"
        flog_success All dotfiles symlinked.
        flog_indent -1
    }

    __zdi_step_40__writing_gitconfig() {
        GITCONFIG_BASEDIR="$(normalize_dir $DOTFILE_PATH lib/gitconfig)"
        if flog_confirm "Set git user.name to $(whoami)?"; then
            git config --global user.name "$(whoami)"
        fi
        if flog_confirm "Set git email and signing key to zetlen@gmail.com?"; then
            git config --global user.email "zetlen@gmail.com"
            gpg --show-key --keyid-format=long "${DOTFILE_PATH}/lib/bootstrap/gpg_z_pub.asc" |
                awk '$1 == "pub" {split($2, a, "/"); print a[2]}' |
                xargs git config --global user.signingkey
        fi
        git config --global include.path "${GITCONFIG_BASEDIR}/common.gitconfig" 'common.gitconfig'
        for TOOL_GITCONFIG in $(find lib/gitconfig -type f -name 'tool.*.gitconfig' -execdir basename {} \;); do
            echo "${TOOL_GITCONFIG}"
            TOOL_NAME="${TOOL_GITCONFIG#tool.}"
            TOOL_NAME="${TOOL_NAME%.gitconfig}"

            if command -v "$TOOL_NAME" &>/dev/null; then
                flog_success "${__flog_color_green}${TOOL_NAME}${__flog_color_normal} is available, adding its include to .gitconfig"
                git config --global include.path "${GITCONFIG_BASEDIR}/${TOOL_GITCONFIG}" "$TOOL_GITCONFIG"
            else
                git config --unset --global include.path "${GITCONFIG_BASEDIR}/${TOOL_GITCONFIG}"
            fi
        done
        flog_success "Built .gitconfig"
    }

    __zdi_step_50__installing_bash_extras() {
        if [ ! -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
            flog_warn "Git prompt not found. Cloning bash-git-prompt repository to .bash-git-prompt"
            git clone --depth=1 https://github.com/magicmonty/bash-git-prompt.git "$HOME/.bash-git-prompt"
        fi
        flog_success "Nice bash prompt installed."
    }

    __zdi_step_60__installing_tool_versions() {
        if i_dont_have rustup; then
            flog_log "Installing rustup"
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
        else
            flog_log "Updating rustup"
            rustup update
        fi
        flog_log "Installing cargo-binstall"
        curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

        if i_dont_have mise; then
            flog_log "Installing mise"
            curl https://mise.run | sh
            touch "~/.config/mise/config.toml"
        fi
        flog_log "Installing all mise versions"
        mise bootstrap

        # For legacy compatibility with scripts that expect asdf
        ln -sf "${HOME}/.local/share/mise" "${HOME}/.asdf"
    }

    __zdi_step_70__setting_up_zsh() {
        if i_dont_have zsh; then
            flog_error "zsh is not installed!"
            return 1
        elif ! grep -qF zsh /etc/shells; then
            flog_error "zsh was not listed as an acceptable shell in /etc/shells!"
            return 1
        elif [[ "$SHELL" = "$(command -v zsh)" ]] || confirm_cmd "sudo usermod --shell $(command -v zsh) $(whoami)"; then
            flog_confirm "Run zsh to set up initial environment?" && zsh "$HOME/.zshrc"
            flog_success "zsh has been installed!"
        fi
    }

    __zdi_step_80__setting_up_editors() {
        # Plain vim: lightweight, vim-plug.
        if [ ! -e ~/.vim/autoload/plug.vim ]; then
            TO_DOWNLOAD="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
            flog_warn "Missing vim plugins."

            flog_log "Downloading ${__flog_startul}${TO_DOWNLOAD}${__flog_endul}"
            curl -fLo ~/.vim/autoload/plug.vim --create-dirs "$TO_DOWNLOAD"
        fi
        flog_success "Vim and vim-plug are installed."
        flog_confirm "Launch vim and update plugins?" && mise x -- vim +PlugUpgrade +PlugUpdate +qall

        # neovim is optional. It costs a neovim build, six language servers and
        # the ACP bridge, which is a lot to force on a box that only ever needs
        # to fix a config file. Both editors read lib/vim/common/, so there is
        # nothing to keep in sync either way -- only plugins differ.
        local nvim_tools_src nvim_tools_dst
        nvim_tools_src="$(normalize_dir "$DOTFILE_PATH" lib/vim/30-editor.toml)"
        nvim_tools_dst="$(normalize_dir "$HOME" .config/mise/conf.d/30-editor.toml)"

        if ! flog_confirm "Set up neovim as well? (LSP, schema validation, Claude via ACP)"; then
            if [ -L "$nvim_tools_dst" ]; then
                rm "$nvim_tools_dst"
                flog_warn "Unlinked $nvim_tools_dst -- mise no longer manages the neovim toolchain."
                flog_warn "Anything already installed stays on disk; 'mise prune' reclaims it."
            fi
            flog_log "Skipping neovim. ~/.config/nvim is inert without it."
            return 0
        fi

        if [ ! -L "$nvim_tools_dst" ]; then
            mkdir -p "$(dirname "$nvim_tools_dst")"
            link_or_warn "$nvim_tools_src" "$nvim_tools_dst" "30-editor.toml" || return 1
        fi
        flog_log "Installing neovim, language servers, and the ACP bridge..."
        mise --yes install || die_bc "mise could not install the neovim toolchain."
        flog_success "neovim $(mise x -- nvim --version | head -1 | cut -d' ' -f2) is installed."

        # vim.pack installs anything missing on first start; this also pulls
        # updates for what is already on disk.
        flog_confirm "Sync neovim plugins?" &&
            mise x -- nvim --headless -c 'lua vim.pack.update(nil, { force = true })' -c 'qa!'
    }

    # ~/.claude/settings.json can be neither symlinked nor `include`d: Claude
    # Code rewrites it in place (/config, /model, /plugin) and its schema has
    # no include directive. So this is the gitconfig treatment, not the vimrc
    # one -- fragments in the repo, deep-merged over an app-owned live file.
    # Only keys a fragment declares are managed; everything else survives.
    #
    # Deliberately left unmanaged, so do not add fragments for them:
    #   model                     names drift; pinning one guarantees a stale
    #                             value later
    #   hooks                     plugins write absolute paths, and the tools
    #                             behind them are not on every host (the herdr
    #                             hook even declares itself herdr-owned and
    #                             overwritten on reinstall)
    #   theme, editorMode,        toggled from inside the app; managing them
    #   effortLevel, tui          means an install run silently reverts /config
    #   permissions.allow,        grown per-host by answering prompts
    #   permissions.defaultMode
    # enabledPlugins is only partly managed: a fragment pins a small core and
    # leaves every other plugin key on the host alone (see the merge helper).
    __zdi_step_90__writing_claude_settings() {
        local claude_dir live frag_dir frag tool
        local frags=()
        claude_dir="$(normalize_dir "$HOME" .claude)"
        live="$(normalize_dir "$claude_dir" settings.json)"
        frag_dir="$(normalize_dir "$DOTFILE_PATH" lib/claude/settings)"

        if i_dont_have jq; then
            flog_error "jq is not installed, so settings fragments cannot be merged."
            return 1
        fi

        mkdir -p "$claude_dir"
        if [ -s "$live" ]; then
            cp "$live" "${live}.bak"
            flog_log "Backed up existing settings to ${live}.bak"
        fi

        for frag in "${frag_dir}"/[0-9]*.json; do
            [ -e "$frag" ] && frags+=("$frag")
        done

        # tool.<command>.json applies only where <command> exists, exactly as
        # tool.*.gitconfig does. Note the asymmetry: git config --unset removes
        # a stale include, but there is no way to subtract merged JSON, so keys
        # from a tool that later disappears linger (inert) in settings.json.
        for frag in "${frag_dir}"/tool.*.json; do
            [ -e "$frag" ] || continue
            tool="${frag##*/tool.}"
            tool="${tool%.json}"
            if i_have "$tool"; then
                flog_success "${__flog_color_green}${tool}${__flog_color_normal} is available, merging $(basename "$frag")"
                frags+=("$frag")
            else
                flog_warn "${tool} not found, skipping $(basename "$frag")"
            fi
        done

        if ((${#frags[@]} == 0)); then
            flog_warn "No settings fragments found in ${frag_dir}"
            return 1
        fi

        merge_json_fragments "$live" "${frags[@]}" || return 1
        flog_success "Merged ${#frags[@]} fragment(s) into ${live}"
    }

    # Defining a step function is registering it: declare -fF lists them in
    # lexicographic order, which is why the NN prefix is zero-padded with gaps
    # of 10, the same convention as lib/common/*.sh and lib/vim/common/*.vim.
    # Two digits sort the way they read where one does not -- a step 9 followed
    # by a step 10 would run the 10th first, ahead of the path check that
    # refuses to install from the wrong directory -- and the gaps leave room to
    # insert a step without renumbering its neighbours.
    #
    # Everything after the second __ is the label, underscores shown as spaces.
    # The counter is the step's position, never its prefix, so renumbering is
    # invisible in the output.
    local __zdi_installers=($(IFS=$'\n' declare -fF | grep -Eo '\b__zdi_step_.+__.*$'))

    local installer
    local label
    local total_steps="${#__zdi_installers[@]}"
    for ((i = 0; i < $total_steps; i++)); do
        installer="${__zdi_installers[$i]}"
        label="${installer#__zdi_step_*__*}"
        flog_log "${__flog_color_standout}${label//_/ }${__flog_color_normal} ($((i + 1)) of $total_steps)"
        if flog_confirm "proceed?"; then
            flog_indent 2
            "$installer"
            flog_indent -2
            echo ''
        fi
    done

    flog_confirm "run new zsh shell to initialize new plugins" &&
        exec zsh -l ||
        flog_warn "next new shell may be slow to load"
}

if [[ "$1" == "-y" ]]; then
    FLOG_CONFIRM_ALL=1
fi

FLOG_CONFIRM_ALL=${FLOG_CONFIRM_ALL} run_dotfile_steps
