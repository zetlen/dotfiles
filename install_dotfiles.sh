#!/bin/bash
# shellcheck disable=SC2059,SC2034

. "$HOME/.dotfiles/lib/common.sh"

# color codes, blank until we know colors are supported
c_standout=""
c_normal=""
c_red=""
c_green=""
c_yellow=""

p_indent_length=0
p_indent=""
__zdi_indent() {
	level="$1"
	p_indent_length="$((p_indent_length + level))"
	p_indent=$(printf "%-${p_indent_length}s")
}

# logfile style
function __zdi_log() {
	echo -e "[INFO]: ${p_indent}$*"
}
function __zdi_warn() {
	echo -e "[WARNING]: ${p_indent}" >&2
	echo -e "$*" >&2
}
function __zdi_error() {
	echo -e "[ERROR]: ${p_indent}" >&2
	echo -e "$*" >&2
}

# but if stdout is a terminal...
if [ -t 1 ]; then

	# see if it supports colors...
	ncolors=$(tput colors)

	if [ -n "$ncolors" ] && [ "$ncolors" -ge 4 ]; then
		c_standout="$(tput smso)"
		c_normal="$(tput sgr0)"
		c_red="$(tput setaf 1)"
		c_green="$(tput setaf 2)"
		c_yellow="$(tput setaf 3)"

		# and make the logging functions human-friendly
		function __zdi_log() {
			echo -e "${p_indent}${*}${c_normal}"
		}
		function __zdi_warn() {
			echo -e "${p_indent}${c_yellow}${*}${c_normal}"
		}
		function __zdi_error() {
			echo -e "\n${c_red}${c_standout}Error: ${*}${c_normal}"
		}

	fi
fi

OSNAME="$(uname)"
MISSING_TOOLS=()
AVAILABLE_TOOLS=()

if REPO_PATH=$(git rev-parse --show-toplevel); then
	TAGFMT="-wip-$(date '+%H%M%Z')"
	__zdi_log "Installing zetlen dotfiles version" "${c_yellow}$(git describe --dirty="$TAGFMT" --tags --always)${c_normal}"
else
	__zdi_error "Cannot continue. This script must be run from the root of the zetlen/dotfiles Git repository, but no Git repository was detected."
fi

# prefixing all the step functions as a namespace
# "__zdi" = "zetlen dotfiles install"

declare -a __zdi_steps

__zdi_steps[1]="Verifying paths"
function __zdi_step1() {
	EXPECTED_REPO_PATH="${HOME}/.dotfiles"
	if [ "$REPO_PATH" != "$EXPECTED_REPO_PATH" ]; then
		__zdi_error "Cannot continue. This repo is located in the directory ${REPO_PATH}, but it only works if it is checked out in ${EXPECTED_REPO_PATH}."
		return 1
	fi
	__zdi_log "${c_green}Repo path is $REPO_PATH"
	if [ "$(pwd)" != "$REPO_PATH" ]; then
		__zdi_error "Cannot continue from current directory $(pwd). This script must be executed from its own directory, which is ${REPO_PATH}."
		return 1
	fi
	__zdi_log "${c_green}Current directory is repo root"
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
	__zdi_log "Required tools for ${OSNAME}:"
	__zdi_indent 1
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

		TOOL_FORMAT="%s%-${PAD_LENGTH}s${c_normal}  %s\n"
		while read -r tool_line; do
			# use parameter substitution to take the first word of the line
			TOOL_NAME="${tool_line%% *}"
			if TOOL_LOC=$(command -v "$TOOL_NAME"); then
				# if it's a function or a builtin, command -v just repeats the command back to you
				if [ "$TOOL_LOC" = "$TOOL_NAME" ]; then
					# and in that case we use "type -t" to say "function" or "builtin"
					TOOL_LOC=$(type -t "$TOOL_NAME")
				fi
				__zdi_log "$(printf "$TOOL_FORMAT" "${c_green}" "$TOOL_NAME" "$TOOL_LOC")"
				AVAILABLE_TOOLS+=("$TOOL_NAME")
			else
				MISSING_TOOLS+=("$tool_line")
				__zdi_warn "$(printf "$TOOL_FORMAT" "${c_red}" "$TOOL_NAME" "${c_standout}${c_red}missing${c_normal}")"
			fi
		done <"$tool_list"
	done
	__zdi_indent -1
	if [ ${#MISSING_TOOLS} -ne '0' ]; then
		__zdi_warn "\nInstall these missing tools for everything to work:"
		__zdi_indent 1
		for tool in "${MISSING_TOOLS[@]}"; do
			# wrap the first word, the command name, in standout tags
			__zdi_warn "${c_standout}${tool%% *}${c_normal} ${c_yellow}${tool#* }"
		done
		__zdi_indent -1
		return 1
	else
		__zdi_log "${c_green}All required tools are present on this system already."
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
	__zdi_log "${c_yellow}Ignoring:"
	__zdi_indent 1
	for to_ignore in "${NOCOPY[@]}"; do
		__zdi_log "$to_ignore"
		NUM_IGNORED=$((NUM_IGNORED + 1))
	done
	for to_ignore in "${NOCOPYTYPE[@]}"; do
		__zdi_log ".${to_ignore} files"
		NUM_IGNORED=$((NUM_IGNORED + 1))
	done
	__zdi_indent -1
	__zdi_log "${c_yellow}Linking:"
	__zdi_indent 1
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
				__zdi_warn "Not symlinking $FILENAME because $TARGET exists and is a symlink to ${EXISTING_SYMLINK}."
				NUM_SKIPPED=$((NUM_SKIPPED + 1))
				continue
			fi
			rm "$TARGET"
		elif [ -e "$TARGET" ]; then
			__zdi_warn "Not symlinking $FILENAME because $TARGET already exists."
			NUM_SKIPPED=$((NUM_SKIPPED + 1))
			continue
		fi
		if ln -s "$file" "$TARGET"; then
			__zdi_log "${c_green}Symlinked ~/${FILENAME} ${c_normal} -> $file"
			NUM_SYMLINKED=$((NUM_SYMLINKED + 1))
		fi
	done
	__zdi_indent -1
	__zdi_log "${c_green}$NUM_SYMLINKED dotfiles symlinked to homedir."
	__zdi_log "$NUM_IGNORED files ignored by ignore rules."
	[ "$NUM_SKIPPED" -gt 0 ] && __zdi_warn "$NUM_SKIPPED files skipped due to conflicts."
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
			__zdi_log "${c_green}${toolname}${c_normal} is available, adding its include to .gitconfig"
			git config --global include.path "$GIT_TOOL_INCLUDE_PATH" "$GIT_TOOL_CONFIG_BASENAME"
		fi
	done
	__zdi_log "${c_green}Built .gitconfig"
}

__zdi_steps[5]="Set up vim"
function __zdi_step5() {
	if command -v vim &>/dev/null; then
		if [ ! -e ~/.vim/autoload/plug.vim ]; then
			TO_DOWNLOAD="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
			__zdi_log "Missing vim plugins."
			__zdi_log "Downloading ${c_yellow}${TO_DOWNLOAD}"
			curl -fLo ~/.vim/autoload/plug.vim --create-dirs "$TO_DOWNLOAD"
		fi
		__zdi_log "${c_green}Vim and vim-plug are installed."
	else
		__zdi_warn "Vim is not installed. No Vim plugins attached."
	fi
}

__zdi_steps[6]="Download bash-only extras"
function __zdi_step6() {
	[ -f "$HOME/.bash-git-prompt/gitprompt.sh" ] || __zdi_warn "Git prompt not found. Clone bash-git-prompt repository to .bash-git-prompt"
	if [ -s "$BASH_VERSION" ] && [ ! -f ~/.git-completion.bash ]; then
		TO_DOWNLOAD="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
		__zdi_log "Missing ~/.git-completion.bash file. Downloading ${c_yellow}$TO_DOWNLOAD"
		curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash >~/.git-completion.bash
	fi
	__zdi_log "${c_green}Git prompt and completion are installed."
	NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
	if [ ! -e "$NVM_DIR/nvm.sh" ]; then
		TO_DOWNLOAD="https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh"
		__zdi_log "nvm is not installed. Downloading and running ${c_yellow}$TO_DOWNLOAD"
		curl -o- "$TO_DOWNLOAD" | bash
	fi
	__zdi_log "${c_green}NVM is installed."
}

TOTAL_STEPS="${#__zdi_steps[@]}"

function __zdi_run_step() {
	local desc
	fn="__zdi_step$1"
	desc="${__zdi_steps[$1]}"
	__zdi_log ''
	__zdi_log "${c_standout}${desc}${c_normal} ($1 of $TOTAL_STEPS)"
	__zdi_indent 2
	"$fn"
	__zdi_indent -2
}

if [ -n "$RUN_STEP" ]; then
	__zdi_run_step "$RUN_STEP"
else
	for stepnum in "${!__zdi_steps[@]}"; do __zdi_run_step "$stepnum"; done
fi
