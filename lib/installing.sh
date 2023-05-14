OSNAME="$(get_os_id)"
OSPATH="$(get_os_dotfile_path)"

die_bc() {
	flog_error "Cannot proceed! $*"
	exit 1
}

confirm_cmd() {
	fmted="$(printf 'Run %s%s%s ?' "$__flog_startul" "$*" "$__flog_endul")"
	flog_confirm "$fmted" && eval "$*"
}
