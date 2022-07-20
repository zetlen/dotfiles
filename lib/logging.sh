
#### friendly logging ####
# color codes, blank until we know colors are supported
__flog_color_standout=""
__flog_color_normal=""
__flog_color_red=""
__flog_color_green=""
__flog_color_yellow=""

__flog_sym_good=""

__flog_tab_len=0
__flog_tab=""

flog_indent() {
	level="$1"
	__flog_tab_len="$((__flog_tab_len + level))"
	__flog_tab=$(printf "%-${__flog_tab_len}s")
}

# fallback style
flog_log() {
	echo -e "[INFO]: ${__flog_tab}$*"
}
flog_warn() {
	echo -e "[WARNING]: ${__flog_tab}$*" >&2
}
flog_error() {
	echo -e "[ERROR]: ${__flog_tab}$*" >&2
}
flog_success() {
	echo -e "[SUCCESS]: ${__flog_tab}$*"
}

# but if stdout is a terminal...
if [ -t 1 ]; then

	# see if it supports colors...
	ncolors=$(tput colors)

	__flog_fancy=1

	if [ -n "$ncolors" ] && [ "$ncolors" -ge 4 ]; then
		__flog_color_standout="$(tput smso)"
		__flog_color_normal="$(tput sgr0)"
		__flog_color_red="$(tput setaf 1)"
		__flog_color_green="$(tput setaf 2)"
		__flog_color_yellow="$(tput setaf 3)"

		__flog_sym_success=$'\xE2\x9C\x94\xEF\xB8\x8E'
		__flog_sym_warn=$'\xE2\x9A\xA0'
		__flog_sym_error=$'\xE2\x9C\x96\xEF\xB8\x8E'

		# and make the logging functions human-friendly
		flog_log() {
			echo -e "${__flog_tab}${*}${__flog_color_normal}"
		}

		__flog_loglevel() {
			local sym
			local prefix
			sym="$1${__flog_color_standout} $2 ${__flog_color_normal}$1"
			shift
			shift
			flog_log "$sym $*"
		}
		flog_warn() {
			__flog_loglevel "$__flog_color_yellow" "$__flog_sym_warn" "$*"
		}
		flog_error() {
			__flog_loglevel "$__flog_color_red" "$__flog_sym_error" "$*"
		}
		flog_success() {
			__flog_loglevel "$__flog_color_green" "$__flog_sym_success" "$*"
		}

	fi
fi
