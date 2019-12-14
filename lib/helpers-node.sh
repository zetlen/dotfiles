#!/bin/sh
n() {
  if [ -f "./yarn.lock" ]; then
    echo yarn.lock detected, running yarn instead
    yarn "$@"
  else
    npm "$@"
  fi
}

nr() {
  if [ -f "./yarn.lock" ]; then
    echo yarn.lock detected, running yarn run instead
    yarn run "$@"
  else
    npm run "$@"
  fi
}

alias nenv='printf "node $(node -v)\nnpm $(npm -v)\nyarn $(yarn --version)\n"'
alias nreset='rm -rf ./node_modules && npm install'
alias y=yarn
alias yr='yarn run'

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"                                       # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
