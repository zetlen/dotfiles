__set_node_aliases() {

	alias n='npm '
	alias nr='npm run '
	alias ni='npm install '
	alias __n_install_all='npm install'
	alias y='yarn '
	alias yr='yarn run '
	alias p='pnpm '
	alias pr='pnpm run '

	local yarnlock="$(find_up yarn.lock)"
	local packagelock="$(find_up package-lock.json)"
	local pnpmlock="$(find_up pnpm-lock.yaml)"

	__yarn_notice="yarn.lock detected, aliasing npm to yarn"
	if [ -n "$yarnlock" ]; then
		alias n="echo $__yarn_notice && yarn "
		alias nr="echo $__yarn_notice && yarn run "
		alias ni="echo $__yarn_notice && yarn add "
		alias __n_install_all="yarn"
	fi

	__pnpm_notice="pnpm-lock.yaml detected, aliasing npm to pnpm"
	if [ -n "$pnpmlock" ]; then
		alias n="echo $__pnpm_notice && pnpm "
		alias nr="echo $__pnpm_notice && pnpm run "
		alias ni="echo $__pnpm_notice && pnpm add "
		alias __n_install_all="pnpm install"
	fi


	alias clean_project='npm run --if-present clean && in_repo && git wash || true'
	alias delete_node_modules='find . -name "node_modules" -type d -prune -exec rm -rf '{}' +'
	alias nenv='printf "node $(node -v)\nnpm $(npm -v)\nyarn $(yarn --version)\n"'
	alias nreset='set -x; clean_project; delete_node_modules; __n_install_all; set +x'
}

add_cd_hook __set_node_aliases
