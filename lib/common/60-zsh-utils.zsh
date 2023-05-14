zsh_show_all_completions() {
	for completion in ${(@k)_comps:#-*(-|-,*)}; do
		printf "%-20s %s\n" $completion "$(command -V $_comps[$completion])"
	done | sort
}
