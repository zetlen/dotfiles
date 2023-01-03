layout_npm() {
	strict_env
	use asdf 2>/dev/null
	layout node 2>/dev/null
	dotenv_if_exists .env

	alias n='npm '
	alias nr='npm run '
	alias ni='npm install '

	local yarnlock="$(find_up yarn.lock)"
	local packagelock="$(find_up package-lock.json)"

	if [ -n "$yarnlock" ]; then
		if [ -n "$packagelock" ]; then
			log_error both package-lock.json and yarn.lock are present, defaulting to npm
		else
			log_status yarn.lock detected, aliasing npm to yarn
			alias n='yarn '
			alias nr='yarn run '
			alias ni='yarn'
		fi
	fi

	alias y='yarn '
	alias yr='yarn run '

	alias clean_project='npm run --if-present clean && on_git_branch && git clean -diX'
	alias delete_node_modules='find . -name "node_modules" -type d -prune -exec rm -rf '{}' +'
	alias nenv='printf "node $(node -v)\nnpm $(npm -v)\nyarn $(yarn --version)\n"'
	alias nreset='set -x; clean_project; delete_node_modules; ni; set +x'
}
