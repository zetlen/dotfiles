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

alias plcat='plutil -convert xml1 -o -'

time_announcements() {
	local arg=$1
	local my_status;
	if [[ "$arg" != "" ]]; then
		if [[ "$arg" != "true" ]] && [[ "$arg" != "false" ]]; then
			echo "Unknown argument: $arg"
			return 1
		else
			defaults write com.apple.speech.synthesis.general.prefs TimeAnnouncementPrefs -dict-add TimeAnnouncementsEnabled -bool $arg
			launchctl kill SIGTERM gui/$UID/com.apple.speech.synthesisserver 2> /dev/null
			launchctl kickstart gui/$UID/com.apple.speech.synthesisserver
			if [[ $arg == "true" ]]; then
				my_status="enabled"
			else 
				my_status="disabled"
			fi
			echo "Time announcements are now $my_status";
		fi
	else
		if defaults read com.apple.speech.synthesis.general.prefs TimeAnnouncementPrefs | grep -qF 'TimeAnnouncementsEnabled = 0'; then
			my_status="disabled"
		else 
			my_status="enabled"
		fi
		echo "Time announcements are currently $my_status"
	fi
}
