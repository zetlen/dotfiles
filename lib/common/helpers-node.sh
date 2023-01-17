__set_node_aliases () {
	 # emulate -L zsh

	alias y='yarn '
	alias yr='yarn run '

	local yarnlock="$(find_up yarn.lock)"
	local packagelock="$(find_up package-lock.json)"

	__yarn_notice="yarn.lock detected, aliasing npm to yarn"

	if [ -n "$yarnlock" ]; then
		if [ -n "$packagelock" ]; then
			__yarn_notice="both package-lock.json and yarn.lock are present, defaulting to npm"
		else
			alias n="echo $__yarn_notice && yarn "
			alias nr="echo $__yarn_notice && yarn run "
			alias ni="echo $__yarn_notice && yarn add "
		fi
	else
			alias n='npm '
			alias nr='npm run '
			alias ni='npm install '
	fi

	alias clean_project='npm run --if-present clean && in_repo && git clean -dfX || true'
	alias delete_node_modules='find . -name "node_modules" -type d -prune -exec rm -rf '{}' +'
	alias nenv='printf "node $(node -v)\nnpm $(npm -v)\nyarn $(yarn --version)\n"'
	alias nreset='set -x; clean_project; delete_node_modules; ni; set +x'
}

add_cd_hook __set_node_aliases
