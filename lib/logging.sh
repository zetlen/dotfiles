
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
flog_confirm() {
	printf "\n[CONFIRM]: %s%s [Y/n]" "${__flog_tab}" "$*"
	read -r
	printf "\n"
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo Y
		return 0
	else
		echo Cancelling
		return 1
	fi
}
flog_log() {
	printf "[INFO]: ${__flog_tab}%s\n" "$*"
}
flog_warn() {
	printf "[WARNING]: ${__flog_tab}%s\n" "$*" >&2
}
flog_error() {
	printf "[ERROR]: ${__flog_tab}%s\n" "$*" >&2
}
flog_success() {
	printf "[SUCCESS]: ${__flog_tab}%s\n" "$*"
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
		__flog_color_confirm="$(tput setaf 4)"

		__flog_sym_confirm=$'\xC2\xBF'
		__flog_sym_success=$'\xE2\x9C\x94\xEF\xB8\x8E'
		__flog_sym_warn=$'\xE2\x9A\xA0'
		__flog_sym_error=$'\xE2\x9C\x96\xEF\xB8\x8E'

		# and make the logging functions human-friendly

		flog_confirm() {
			printf "\n"
			__flog_loglevel "$__flog_color_normal" "$__flog_sym_confirm" "$* [Y/n]"
			read -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				echo Y
				return 0
			else
				flog_error Cancelling
				return 1
			fi
		}

		flog_log() {
			printf "${__flog_tab}%s${__flog_color_normal}\n" "$*"
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
