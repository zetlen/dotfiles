#!/usr/bin/env zsh

if [ "$IN_TMUX" -eq "1" ]; then
	tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel pbcopy
fi

random_word() {
	perl -e 'srand; rand($.) < 1 && ($line = $_) while <>; print $line;' /usr/share/dict/words
}

googlebot() {
	# tell shellcheck to allow this stupid command to run forever
	# shellcheck disable=2207
	voices=($(say -v '?' | awk '{print $1}'))
	while :; do random_word | tee /dev/tty | say -v "${voices[$RANDOM % ${#voices[@]}]}"; done
}


if type brew &>/dev/null; then
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
