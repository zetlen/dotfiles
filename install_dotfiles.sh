#!/bin/bash
# shellcheck disable=SC2059,SC2034

. "$HOME/.dotfiles/lib/common.sh"
. "$HOME/.dotfiles/lib/logging.sh"

OSNAME="$(get_os_id)"
OSPATH="$(get_os_dotfile_path)"

die_bc() {
	flog_error "Cannot proceed! $*"
	exit 1
}

confirm_cmd() {
	fmted="$(printf 'Run %s%s%s ?' "$__flog_startul" "$*" "$__flog_endul")"
	flog_confirm "$fmted" && eval "$*"
}

__pkg_is_installed() {
	! i_dont_have "$1"
}

__pkg_is_available() {
	false
}

__pkg_expected=(
	zsh
	git
	curl
	vim
	fzf
	gpg
	lsof
	rsync
	jq
)

__pkg_install_all() {
	flog_warning "Could not detect what package manager to use. The following commands are expected in PATH:"
	__pkg_get_installable
	flog_warning "Install may fail without missing packages."
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
	if (( ${#installed_pkgs[@]} )); then
		flog_success "Already installed: ${installed_pkgs[*]}"
	fi
	if (( ${#unavailable_pkgs[@]} )); then
		flog_error "Package manager doesn't have: ${unavailable_pkgs[*]}"
	fi
	if (( ${#to_install[@]} )); then
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

# prefixing all the step functions as a namespace
# "__zdi" = "zetlen dotfiles install"

declare -a __zdi_steps

__zdi_steps[1]="Verifying paths"
__zdi_step1() {
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

__zdi_steps[2]="Install packages?"
__zdi_step2() {
	if [ ! -e "${OSPATH}/install.sh" ]; then
		flog_warn "No install script for OS "$OSNAME" present."
	else
		. "${OSPATH}/install.sh" || die_bc "Error running install script ${OSPATH}/install.sh"
		__pkg_install_all
	fi
}

__zdi_steps[3]="Symlinking dotfiles to homedir"
__zdi_step3() {
	flog_indent 1
	src_dir="$(normalize_dir $DOTFILE_PATH skel)"
	for f in $(cd $src_dir && find . -type f -exec bash -c 'echo ${0:2}' {} \;); do
		src_path="$(normalize_dir $src_dir $f)"
		tgt_path="$(normalize_dir $HOME $f)"
		tgt_dir="$(dirname $tgt_path)" 
		if [ ! -d "$tgt_dir" ]; then
			flog_log Creating directory $tgt_dir
			mkdir -p "$tgt_dir"
		fi
		if [ -L "$tgt_path" ]; then
			tgt_orig="$(readlink $tgt_path)"
			tgt_orig="$(normalize_dir $tgt_orig)"
			if [ "$tgt_orig" == "$src_path" ]; then
				flog_log "$f is already symlinked to $src_path"
			elif [ "${tgt_orig#$DOTFILE_PATH}" == "$tgt_orig" ]; then
				flog_warn "Not symlinking $src_path because $f is already symlinked to $tgt_orig."
			else
				flog_log "Updating symlink of $f to $src_path"
				rm "$tgt_path"
				ln -s "$src_path" "$tgt_path"
				flog_success "Symlinked $f to $src_path"
			fi
		elif [ -f "$tgt_path" ]; then
			flog_warn "Not symlinking $src_path because $tgt_path already exists."
		else
			ln -s "$src_path" "$tgt_path"
			flog_success "Symlinked $f to $src_path"
		fi
	done
	flog_success All dotfiles symlinked.
}

__zdi_steps[4]="Writing gitconfig"
__zdi_step4() {
	GITCONFIG_BASEDIR="$(normalize_dir $DOTFILE_PATH lib/gitconfig)"
  git config --global user.name "$(whoami)"
	if flog_confirm "Set git user.email to zetlen@gmail.com?" ; then
		git config --global user.email "zetlen@gmail.com"
	fi
	git config --global include.path "${GITCONFIG_BASEDIR}/common.gitconfig" 'common.gitconfig'
	for TOOL_GITCONFIG in $(find lib/gitconfig -type f -name 'tool.*.gitconfig' -execdir echo {} \;); do
		TOOL_NAME="${TOOL_GITCONFIG#tool.}"
		TOOL_NAME="${TOOL_NAME%.gitconfig}"

		if command -v "$TOOL_NAME" &>/dev/null; then
			flog_success "${__flog_color_green}${TOOL_NAME}${__flog_color_normal} is available, adding its include to .gitconfig"
			git config --global include.path "${GITCONFIG_BASEDIR}/${TOOL_GITCONFIG}" "$TOOL_GITCONFIG"
		fi
	done
	flog_success "Built .gitconfig"
}

__zdi_steps[5]="Download bash-only extras"
__zdi_step5() {
	if [ ! -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    flog_warn "Git prompt not found. Cloning bash-git-prompt repository to .bash-git-prompt"
    git clone --depth=1 https://github.com/magicmonty/bash-git-prompt.git "$HOME/.bash-git-prompt"
  fi
	if [ -s "$BASH_VERSION" ] && [ ! -f ~/.git-completion.bash ]; then
		TO_DOWNLOAD="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
		flog_warn "Missing ~/.git-completion.bash file. Downloading ${__flog_startul}${TO_DOWNLOAD}${__flog_endul}"
		curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash >~/.git-completion.bash
	fi
	flog_success "Git prompt and completion are installed."
}


__zdi_steps[6]="Set up vim"
__zdi_step6() {
	if ! i_dont_have vim; then
		if [ ! -e ~/.vim/autoload/plug.vim ]; then
			TO_DOWNLOAD="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
			flog_warn "Missing vim plugins."

			flog_log "Downloading ${__flog_startul}${TO_DOWNLOAD}${__flog_endul}"
			curl -fLo ~/.vim/autoload/plug.vim --create-dirs "$TO_DOWNLOAD"
		fi
		flog_success "Vim and vim-plug are installed."
		flog_confirm "Launch vim and update plugins?" && vim +PlugUpgrade +PlugUpdate +qall
	else
		flog_warn "Vim is not installed. No Vim plugins attached."
	fi
}
__zdi_steps[7]="Set up zsh"
__zdi_step7() {
	if i_dont_have zsh; then
		flog_error "zsh is not installed!"
		return 1
	elif ! grep -qF zsh /etc/shells; then
		flog_error "zsh was not listed as an acceptable shell in /etc/shells!"
		return 1
	elif confirm_cmd "sudo usermod --shell $(which zsh) $(whoami)"; then
		flog_confirm "Run zsh to set up initial environment?" && zsh
		flog_success "zsh has been installed!"
	fi
}

TOTAL_STEPS="${#__zdi_steps[@]}"

__zdi_run_step() {
	local desc
	fn="__zdi_step$1"
	desc="${__zdi_steps[$1]}"
	flog_log ''
	flog_log "${__flog_color_standout}${desc}${__flog_color_normal} ($1 of $TOTAL_STEPS)"
	if flog_confirm "Proceed?"; then
		flog_indent 2
		"$fn"
		flog_indent -2
	fi
}

if [ ! -d "$OSPATH" ]; then
	die_bc "Unknown OS '${OSNAME}'. Gotta install everything manually."
fi

if [ -n "$RUN_STEP" ]; then
	__zdi_run_step "$RUN_STEP"
else
	for stepnum in "${!__zdi_steps[@]}"; do __zdi_run_step "$stepnum"; done
fi
