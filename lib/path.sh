# void z_path(str dirname, ...)
#
# Append each passed existing directory to the current user's ${PATH} in a
# safe manner silently ignoring:
#
# * Relative directories (i.e., *NOT* prefixed by the directory separator).
# * Duplicate directories (i.e., already listed in the current ${PATH}).
# * Nonextant directories.
_z_path() {
	# For each passed dirname...
	local dirname
	for dirname; do
		# Strip the trailing directory separator if any from this dirname,
		# reducing this dirname to the canonical form expected by the
		# test for uniqueness performed below.
		dirname="${dirname%/}"

		# If this dirname is either relative, duplicate, or nonextant, then
		# silently ignore this dirname and continue to the next. Note that the
		# extancy test is the least performant test and hence deferred.
		# UPDATE apr 2023 do not care if it doesn't exist

		[[ "${dirname:0:1}" == '/' && ":${PATH}:" != *":${dirname}:"* ]] || continue

		# Else, this is an existing absolute unique dirname. In this case,
		# append this dirname to the current ${PATH}.
		PATH="${PATH}:${dirname}"
	done

	# Strip an erroneously leading delimiter from the current ${PATH} if any,
	# a common edge case when the initial ${PATH} is the empty string.
	PATH="${PATH#:}"

	# Export the current ${PATH} to subprocesses. Although system-wide scripts
	# already export the ${PATH} by default on most systems, "Bother free is
	# the way to be."
	export PATH
}

_z_path "$HOME/bin" \
	"$HOME/.local/bin" \
	"$HOME/.cargo/bin" \
	"$HOME/.composer/vendor/bin" \
	"$HOME/.rvm/bin" \
	"$HOME/Library/Python/3.9/bin" \
	"$HOME/.yarn/bin" \
	"$HOME/.local/share/pnpm" \
	"$HOME/.config/yarn/global/node_modules/.bin" \
	"/usr/local/share/npm/bin" \
	"/usr/local/bin" \
	"/usr/local/sbin" \
	"/opt/local/bin" \
	"/opt/local/sbin"
