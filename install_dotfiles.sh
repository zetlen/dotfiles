#!/bin/bash
# shellcheck disable=SC2059,SC2034

. "$HOME/.dotfiles/lib/common.sh"

OSNAME="$(uname)"
MISSING_TOOLS=()
AVAILABLE_TOOLS=()

if REPO_PATH=$(git rev-parse --show-toplevel); then
	TAGFMT="-wip-$(date '+%H%M%Z')"
	flog_log "Installing zetlen dotfiles version" "${__flog_color_yellow}$(git describe --dirty="$TAGFMT" --tags --always)${__flog_color_normal}"
else
	flog_error "Cannot continue. This script must be run from the root of the zetlen/dotfiles Git repository, but no Git repository was detected."
fi

# prefixing all the step functions as a namespace
# "__zdi" = "zetlen dotfiles install"

declare -a __zdi_steps

__zdi_steps[1]="Verifying paths"
function __zdi_step1() {
	EXPECTED_REPO_PATH="${HOME}/.dotfiles"
	if [ "$REPO_PATH" != "$EXPECTED_REPO_PATH" ]; then
		flog_error "Cannot continue. This repo is located in the directory ${REPO_PATH}, but it only works if it is checked out in ${EXPECTED_REPO_PATH}."
		return 1
	fi
	flog_success "Repo path is $REPO_PATH"
	if [ "$(pwd)" != "$REPO_PATH" ]; then
		flog_error "Cannot continue from current directory $(pwd). This script must be executed from its own directory, which is ${REPO_PATH}."
		return 1
	fi
	flog_success "Current directory is repo root"
}

__zdi_steps[2]="Checking for required tools"
function __zdi_step2() {
	# change the separator during this function so it can
	# be reasonable about newlines
	__OLDIFS="$IFS"
	IFS=$'\n'

	REQUIRED_TOOLS=("${DOTFILE_PATH}lib/common.required_tools.txt")

	OS_REQUIRED_TOOLS="${DOTFILE_PATH}lib/os.${OSNAME}.required_tools.txt"
	if [ -s "$OS_REQUIRED_TOOLS" ]; then
		REQUIRED_TOOLS+=("$OS_REQUIRED_TOOLS")
	fi
	flog_log "Required tools for ${OSNAME}:"
	flog_indent 1
	PAD_LENGTH=6
	for tool_list in "${REQUIRED_TOOLS[@]}"; do
		# pad out the first column to the width of the longest command name
		while read -r tool_line; do
			# tool command name is the first word of each line
			# shellcheck disable=SC2001
			TOOL_NAME=$(echo "$tool_line" | sed 's/ .*//')
			if [ "${#TOOL_NAME}" -ge $PAD_LENGTH ]; then
				PAD_LENGTH=${#TOOL_NAME}
			fi
		done <"$tool_list"

		TOOL_FORMAT="%s%-${PAD_LENGTH}s${__flog_color_normal}  %s\n"
		while read -r tool_line; do
			# use parameter substitution to take the first word of the line
			TOOL_NAME="${tool_line%% *}"
			if TOOL_LOC=$(command -v "$TOOL_NAME"); then
				# if it's a function or a builtin, command -v just repeats the command back to you
				if [ "$TOOL_LOC" = "$TOOL_NAME" ]; then
					# and in that case we use "type -t" to say "function" or "builtin"
					TOOL_LOC=$(type -t "$TOOL_NAME")
				fi
				flog_log "$(printf "$TOOL_FORMAT" "${__flog_color_green}" "$TOOL_NAME" "$TOOL_LOC")"
				AVAILABLE_TOOLS+=("$TOOL_NAME")
			else
				MISSING_TOOLS+=("$tool_line")
				flog_warn "$(printf "$TOOL_FORMAT" "${__flog_color_red}" "$TOOL_NAME" "${__flog_color_standout}${__flog_color_red}missing${__flog_color_normal}")"
			fi
		done <"$tool_list"
	done
	flog_indent -1
	if [ ${#MISSING_TOOLS} -ne '0' ]; then
		flog_warn "\nInstall these missing tools for everything to work:"
		flog_indent 1
		for tool in "${MISSING_TOOLS[@]}"; do
			# wrap the first word, the command name, in standout tags
			flog_warn "${__flog_color_standout}${tool%% *}${__flog_color_normal} ${__flog_color_yellow}${tool#* }"
		done
		flog_indent -1
		return 1
	else
		flog_success "All required tools are present on this system already."
	fi
	IFS="$__OLDIFS"
}

__zdi_steps[3]="Symlinking dotfiles to homedir"
function __zdi_step3() {
	NOCOPY=('.' '..' '.git' '.gitignore' '.editorconfig' '.shellcheckrc')
	NOCOPYTYPE=('swp')
	NUM_SYMLINKED=0
	NUM_IGNORED=0
	NUM_SKIPPED=0
	flog_log "Ignoring:"
	flog_indent 1
	for to_ignore in "${NOCOPY[@]}"; do
		flog_log "$to_ignore"
		NUM_IGNORED=$((NUM_IGNORED + 1))
	done
	for to_ignore in "${NOCOPYTYPE[@]}"; do
		flog_log ".${to_ignore} files"
		NUM_IGNORED=$((NUM_IGNORED + 1))
	done
	flog_indent -1
	flog_log "${__flog_color_yellow}Linking:"
	flog_indent 1
	for file in "${REPO_PATH}"/.*; do
		FILENAME=$(basename "$file")
		TARGET=~/"$FILENAME"
		for to_ignore in "${NOCOPY[@]}"; do
			if [ "$FILENAME" == "$to_ignore" ]; then
				continue 2
			fi
		done
		for to_ignore in "${NOCOPYTYPE[@]}"; do
			if [ "${FILENAME##*.}" == "$to_ignore" ]; then
				continue 2
			fi
		done
		if [ -L "$TARGET" ]; then
			EXISTING_SYMLINK=$(realpath "$TARGET")
			if [ "$file" != "$EXISTING_SYMLINK" ]; then
				flog_warn "Not symlinking $FILENAME because $TARGET exists and is a symlink to ${EXISTING_SYMLINK}."
				NUM_SKIPPED=$((NUM_SKIPPED + 1))
				continue
			fi
			rm "$TARGET"
		elif [ -e "$TARGET" ]; then
			flog_warn "Not symlinking $FILENAME because $TARGET already exists."
			NUM_SKIPPED=$((NUM_SKIPPED + 1))
			continue
		fi
		if ln -s "$file" "$TARGET"; then
			flog_log "${__flog_color_green}Symlinked ~/${FILENAME} ${__flog_color_normal} -> $file"
			NUM_SYMLINKED=$((NUM_SYMLINKED + 1))
		fi
	done
	flog_indent -1
	flog_log "$NUM_IGNORED files ignored by ignore rules."
	flog_success "$NUM_SYMLINKED dotfiles symlinked to homedir."
	[ "$NUM_SKIPPED" -gt 0 ] && flog_warn "$NUM_SKIPPED files skipped due to conflicts."
}

__zdi_steps[4]="Writing gitconfig"
function __zdi_step4() {
	git config --global include.path "${DOTFILE_PATH}"lib/gitconfig/common.gitconfig 'common.gitconfig'
	OSGITCONFIG="${DOTFILE_PATH}lib/gitconfig/os.${OSNAME}.gitconfig"
	[ -f "$OSGITCONFIG" ] && git config --global include.path "$OSGITCONFIG" "os.${OSNAME}.gitconfig"

	for toolname in "${AVAILABLE_TOOLS[@]}"; do
		GIT_TOOL_CONFIG_BASENAME="tool.${toolname}.gitconfig"
		GIT_TOOL_INCLUDE_PATH="${REPO_PATH}/lib/gitconfig/${GIT_TOOL_CONFIG_BASENAME}"
		if [ -s "$GIT_TOOL_INCLUDE_PATH" ]; then
			flog_success "${__flog_color_green}${toolname}${__flog_color_normal} is available, adding its include to .gitconfig"
			git config --global include.path "$GIT_TOOL_INCLUDE_PATH" "$GIT_TOOL_CONFIG_BASENAME"
		fi
	done
	flog_success "Built .gitconfig"
}

__zdi_steps[5]="Set up vim"
function __zdi_step5() {
	if command -v vim &>/dev/null; then
		if [ ! -e ~/.vim/autoload/plug.vim ]; then
			TO_DOWNLOAD="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
			flog_warn "Missing vim plugins."
			flog_log "Downloading ${__flog_color_yellow}${TO_DOWNLOAD}"
			curl -fLo ~/.vim/autoload/plug.vim --create-dirs "$TO_DOWNLOAD"
		fi
		flog_success "Vim and vim-plug are installed."
	else
		flog_warn "Vim is not installed. No Vim plugins attached."
	fi
}

__zdi_steps[6]="Download bash-only extras"
function __zdi_step6() {
	[ -f "$HOME/.bash-git-prompt/gitprompt.sh" ] || flog_warn "Git prompt not found. Clone bash-git-prompt repository to .bash-git-prompt"
	if [ -s "$BASH_VERSION" ] && [ ! -f ~/.git-completion.bash ]; then
		TO_DOWNLOAD="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
		flog_warn "Missing ~/.git-completion.bash file. Downloading $TO_DOWNLOAD"
		curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash >~/.git-completion.bash
	fi
	flog_success "Git prompt and completion are installed."
	NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
	if [ ! -e "$NVM_DIR/nvm.sh" ]; then
		TO_DOWNLOAD="https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh"
		flog_warn "nvm is not installed. Downloading and running $TO_DOWNLOAD"
		curl -o- "$TO_DOWNLOAD" | bash
	fi
	flog_success "NVM is installed."
}

TOTAL_STEPS="${#__zdi_steps[@]}"

function __zdi_run_step() {
	local desc
	fn="__zdi_step$1"
	desc="${__zdi_steps[$1]}"
	flog_log ''
	flog_log "${__flog_color_standout}${desc}${__flog_color_normal} ($1 of $TOTAL_STEPS)"
	flog_indent 2
	"$fn"
	flog_indent -2
}

if [ -n "$RUN_STEP" ]; then
	__zdi_run_step "$RUN_STEP"
else
	for stepnum in "${!__zdi_steps[@]}"; do __zdi_run_step "$stepnum"; done
fi
