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
alias delete_node_modules='find . -name "node_modules" -type d -prune -exec rm -rf '{}' +'
alias clean_repo='npm run --if-present clean; git clean -dfX'
alias yarn_or_npm_install='if [ -f yarn.lock ]; then yarn; else npm install; fi'
alias nreset='set -x; clean_repo; delete_node_modules; yarn_or_npm_install; set +x'
alias y=yarn
alias yr='yarn run'
