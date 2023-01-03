__find_up () {
  local path=$(pwd)
	while [[ "$path" != "" && ! -e "$path/$1" ]]; do
		path=${path%/*}
	done
	echo "$path"
}

__set_node_aliases () {
	 emulate -L zsh

	alias y='yarn '
	alias yr='yarn run '

	local yarnlock="$(__find_up yarn.lock)"
	local packagelock="$(__find_up package-lock.json)"

	if [ -n "$yarnlock" ]; then
		if [ -n "$packagelock" ]; then
			echo both package-lock.json and yarn.lock are present, defaulting to npm
		else
			echo yarn.lock detected, aliasing npm to yarn
			alias n='yarn '
			alias nr='yarn run '
			alias ni='yarn add '
		fi
	else
			alias n='npm '
			alias nr='npm run '
			alias ni='npm install '
	fi

	alias clean_project='npm run --if-present clean && on_git_branch && git clean -diX'
	alias delete_node_modules='find . -name "node_modules" -type d -prune -exec rm -rf '{}' +'
	alias nenv='printf "node $(node -v)\nnpm $(npm -v)\nyarn $(yarn --version)\n"'
	alias nreset='set -x; clean_project; delete_node_modules; ni; set +x'
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd __set_node_aliases
