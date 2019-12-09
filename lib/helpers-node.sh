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
