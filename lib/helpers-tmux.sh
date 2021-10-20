#!/bin/sh

if command -v tmux >/dev/null && contains "$TERM" "screen" && [ -n "$TMUX" ]; then
	IN_TMUX="1"
	GPG_TTY=$(tty)
else
	IN_TMUX=
fi

tma() {
	if [ "$IN_TMUX" -eq "1" ]; then
		echo Already in tmux.
		return 1
	fi
	sname=$1
	if [ -z "$1" ]; then
		sname="main"
	fi
	tmux attach -d -t $sname || tmux new -s $sname
}

tmuxwinname() {
	if [ "$IN_TMUX" -eq "1" ]; then
		tmux rename-window "$1"
	fi
}
