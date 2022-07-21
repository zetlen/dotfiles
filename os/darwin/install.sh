#!/bin/bash

. "$HOME/.dotfiles/lib/logging.sh"

i_dont_have() {
	! command -v "$1" &>/dev/null
}

if i_dont_have git; then
	flog_warn "git isn't installed."
	flog_confirm "install with 'xcode-select --install'?" && xcode-select --install
fi
if i_dont_have brew; then
	flog_warn "brew isn't installed."
	flog_confirm 'install with /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"?'
fi
if i_dont_have brew; then
	flog_warn "Without brew, we can't install vim, asdf, exa, git-delta or many other things"
else
	if flog_confirm "Install vim, asdf, exa, git-delta with brew?"; then
		brew install vim && brew install asdf && brew install exa && brew install git-delta
	fi
	if i_dont_have ksdiff; then
		flog_confirm "Go to https://kaleidoscope.app to install Kaleidoscope diff?" && open https://kaleidoscope.app
	fi
	if i_dont_have gpg; then
		flog_confirm "Go to https://gpgtools.org/ to install GPG?" && open https://gpgtools.org
	fi
fi
