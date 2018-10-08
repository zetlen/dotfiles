#!/bin/bash

n() {
  if [ -f "./yarn.lock" ]; then
    printf "A yarn.lock file is present in this folder.\\nUse 'npm' to force using npm, or use 'y' for yarn instead.\\n"
    return 1;
  fi
  npm "$@"
}
alias nr='npm run'
alias nenv='printf "node $(node -v)\nnpm $(npm -v)\nyarn $(yarn --version)\n"'
alias nreset='rm -rf ./node_modules && npm install'
alias y=yarn
alias yr='yarn run'
