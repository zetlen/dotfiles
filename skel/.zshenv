__dotfiles_profile="$HOME/.profile"
[ -r "$__dotfiles_profile" ] || __dotfiles_profile="$HOME/.dotfiles/skel/.profile"
[ -r "$__dotfiles_profile" ] && . "$__dotfiles_profile"

[ -r "$HOME/.dotfiles/lib/runtimes.sh" ] && . "$HOME/.dotfiles/lib/runtimes.sh"

# .profile skips its setup block when __DOTFILES_PROFILE_LOADED is inherited,
# but the inherited PATH may have been reordered since the parent shell ran
# (macOS path_helper demotes Homebrew in every login shell, and non-login
# shells never heal it otherwise). The function is defined unconditionally,
# so re-assert PATH order in every zsh.
command -v __dotfiles_setup_path >/dev/null 2>&1 && __dotfiles_setup_path

unset __dotfiles_profile
