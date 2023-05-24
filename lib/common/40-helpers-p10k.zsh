#!/bin/zsh

_p10k_toggle_versions() {
	p10k display '*/asdf'=hide,show
}

_p10k_hide_versions() {
	p10k display '*/asdf'=hide
}

_p10k_show_versions() {
	p10k display '*/asdf'=show
}
