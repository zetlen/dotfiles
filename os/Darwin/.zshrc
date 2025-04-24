#!/usr/bin/env zsh

eval "$([[ -x "/opt/homebrew/bin/brew" ]] && /opt/homebrew/bin/brew shellenv)"

if [ "$IN_TMUX" -eq "1" ]; then
	tmux bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel pbcopy
fi

if type brew &>/dev/null; then
  fpath+=("$(brew --prefix)/share/zsh/site-functions")
fi

alias plcat='plutil -convert xml1 -o -'

i_have jq && i_have system_profiler && export MACOS_SYSTEM_AUDIO_DEVICE_NAME="$(system_profiler SPAudioDataType -json | jq -r '.SPAudioDataType[] | select(._name == "coreaudio_device") | ._items[] | select(._properties == "coreaudio_default_audio_system_device") | .coreaudio_output_source')"
