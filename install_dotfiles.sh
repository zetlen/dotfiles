#!/bin/bash

. "$HOME/.dotfiles/lib/common.sh"

# prefixing all the functions as a namespace
# "__zdi" = "zetlen dotfiles install"

# color codes, blank until we know colors are supported
c_standout=""
c_normal=""
c_red=""
c_green=""
c_yellow=""
 
# logfile style
function __zdi_log() {
  echo -e "[INFO]: $*"
}
function __zdi_warn() {
  echo -e "[WARNING]: " >&2
  echo -e "$*" >&2
}
function __zdi_error() {
  echo -e "[ERROR]: " >&2
  echo -e "$*" >&2
}

# but if stdout is a terminal...
if [ -t 1 ]; then

    # see if it supports colors...
    ncolors=$(tput colors)

    if [ -n "$ncolors" ] && [ $ncolors -ge 4 ]; then
        c_standout="$(tput smso)"
        c_normal="$(tput sgr0)"
        c_red="$(tput setaf 1)"
        c_green="$(tput setaf 2)"
        c_yellow="$(tput setaf 3)"

        # and make the logging functions human-friendly
        function __zdi_log() {
          echo -e "${*}${c_normal}"
        }
        function __zdi_warn() {
          echo -e "${c_yellow}${*}${c_normal}"
        }
        function __zdi_error() {
          echo -e "${c_red}${c_standout}${*}${c_normal}"
        }

    fi
fi

OSNAME="$(uname)"
MISSING_TOOLS=()

function __zdi_1_verify_paths() {
  REPO_PATH=$(git rev-parse --show-toplevel)
  # test exit code of the last command
  if [ "$?" -ne "0" ]; then
    __zdi_error "Cannot continue. This script must be run from the root of the zetlen/dotfiles Git           repository, but no Git repository was detected."
    return 1
  fi
  EXPECTED_REPO_PATH="${HOME}/.dotfiles"
  if [ $REPO_PATH != $EXPECTED_REPO_PATH ]; then
    __zdi_error "Cannot continue. This repo is located in the directory ${REPO_PATH}, but it only works      if it is checked out in ${EXPECTED_REPO_PATH}."
    return 1
  fi
  if [ "$(pwd)" != "$REPO_PATH" ]; then
    __zdi_error "Cannot continue from current directory "$(pwd)". This script must be executed from its own directory, which is ${REPO_PATH}."
  fi
}

function __zdi_2_require_tools() {
  # change the separator during this function so it can
  # be reasonable about newlines
  __OLDIFS="$IFS"
  IFS=$'\n'

  MISSING_TOOLS=()

  OSREQUIRED="${DOTFILE_PATH}lib/os.${OSNAME}.required_tools.txt"

  if [ -z "$OSREQUIRED" ]; then
    __zdi_log "No required tools need to be installed for ${OSNAME}".
  else
    __zdi_log "Required tools for ${OSNAME}:"

    # pad out the first column to the width of the longest command name
    PAD_LENGTH=6
    while read tool_line; do
      # tool command name is the first word of each line
      TOOL_NAME=$(echo "$tool_line" | sed 's/ .*//')
      if [ "${#TOOL_NAME}" -ge $PAD_LENGTH ]; then
        PAD_LENGTH=${#TOOL_NAME}
      fi
    done <$OSREQUIRED

    TOOL_FORMAT=" %s%-${PAD_LENGTH}s${c_normal}  %s\n"
    while read tool_line; do
      TOOL_NAME=$(echo "$tool_line" | awk '{print $1}')
      TOOL_LOC=$(command -v $TOOL_NAME)
      if [ "$?" -eq "0" ]; then
        # if it's a function or a builtin, command -v just repeats the command back to you
        if [ "$TOOL_LOC" = "$TOOL_NAME" ]; then
          # and in that case we use "type -t" to say "function" or "builtin"
          TOOL_LOC=$(type -t $TOOL_NAME);
        fi
        printf "$TOOL_FORMAT" "${c_green}" "$TOOL_NAME" "$TOOL_LOC"
      else
        MISSING_TOOLS+=("$tool_line")
        printf "$TOOL_FORMAT" "${c_red}" "$TOOL_NAME" "${c_standout}${c_red}missing${c_normal}"
      fi
    done <$OSREQUIRED

    if [ ${#MISSING_TOOLS} -ne '0' ]; then
      __zdi_warn "\nInstall these missing tools for everything to work:"
      for tool in ${MISSING_TOOLS[@]}; do
        # wrap the first word, the command name, in standout tags
        echo $tool | sed '/^[a-zA-Z]/ s!\([^ ]*\)! - '"${c_yellow}${c_standout}"'\1'"$c_normal"'!'
      done
      return 1
    else
      __zdi_log "${green}All required tools are present on this system already."
    fi
  fi
  IFS="$__OLDIFS"
}

function __zdi_3_symlink_files() {
  SYMLINKED=0
  REPO_PATH=$(git rev-parse --show-toplevel)
  for file in ${REPO_PATH}/.*; do
    FILENAME=$(basename "$file")
    TARGET=~/"$FILENAME"
    for nocopy in . .. .git .gitignore; do
      if [ "$FILENAME" == "$nocopy" ]; then
        __zdi_log Skipping $nocopy
        continue 2
      fi
    done
    if [ "${FILENAME##*.}" == "swp" ]; then
      __zdi_log Skipping $nocopy
      continue
    fi
    if [ -L "$TARGET" ]; then
      EXISTING_SYMLINK="$(realpath $TARGET)"
      if [ "$file" != "$EXISTING_SYMLINK" ]; then
        __zdi_warn "Not symlinking $FILENAME because $TARGET exists and is a symlink to ${EXISTING_SYMLINK}."
        continue
      fi
      __zdi_log Removing existing symlink "$TARGET"
      rm $TARGET
    elif [ -e "$TARGET" ]; then
      __zdi_warn "Not symlinking $FILENAME because $TARGET already exists."
      continue
    fi
    __zdi_log Symlinking $FILENAME
    ln -s "$file" "$TARGET" && SYMLINKED=$((SYMLINKED + 1))
  done
  __zdi_log "$SYMLINKED dotfiles symlinked to homedir."
}


function __zdi_4_write_gitconfig() {
  __zdi_log 'Writing .gitconfig...'
  git config --global include.path ${DOTFILE_PATH}lib/gitconfig/common.gitconfig 'common.gitconfig'
  OSGITCONFIG="${DOTFILE_PATH}lib/gitconfig/os.${OSNAME}.gitconfig"
  [ -f "$OSGITCONFIG" ] && git config --global include.path $OSGITCONFIG "os.${OSNAME}.gitconfig"

  for file in ${REPO}/lib/gitconfig/tool.*.gitconfig; do
    TOOLBASENAME="$(basename $file)"
    printf '%s...' $TOOLBASENAME >&2
    sleep 2
    TOOLNAME="${TOOLBASENAME#tool.}"
    TOOLNAME="${TOOLNAME%.gitconfig}"
    if command -v "$TOOLNAME" &>/dev/null; then
      printf ' %sfound%s in %s, adding %s \n' "${c_green}" "${c_normal}" "$(which $TOOLNAME)" "$TOOLBASENAME"
      git config --global include.path $file "${TOOLBASENAME}"
    else
      printf ' %snot found in PATH%s, skipping include %s \n' "${c_yellow}" "${c_normal}" "$TOOLBASENAME"
    fi
  done

  __zdi_log 'Wrote gitconfig includes:'
  git config --show-origin --global --get-all include.path

}

function __zdi_5_load_vim_plugins() { 
  if command -v vim &>/dev/null; then
    if [ ! -d ~/.vim/autoload/plug.vim ]; then
      curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
  else
    __zdi_warn "Vim is not installed. No Vim plugins attached."
  fi
}

function __zdi_6_load_bash_git_completion() {
  if [ -s "$BASH_VERSION" ] && [ ! -f ~/.git-completion.bash ]; then
    curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/.git-completion.bash
  fi
}

__zdi_2_require_tools

# __zdi_1_verify_paths && __zdi_2_require_tools && __zdi_3_symlink_files && __zdi_4_write_config && __zdi_5_load_vim_plugins && __zdi_6_load_bash_git_completion
