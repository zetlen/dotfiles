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

sync_links_from_dir() {
	src_dir="$1"
	for f in $(cd $src_dir && find . -type f -exec bash -c 'echo ${0:2}' {} \;); do
		src_path="$(normalize_dir $src_dir $f)"
		tgt_path="$(normalize_dir $HOME $f)"
		tgt_dir="$(dirname $tgt_path)"
		if [ ! -d "$tgt_dir" ]; then
			flog_log Creating directory $tgt_dir
			mkdir -p "$tgt_dir"
		fi
		if [ -L "$tgt_path" ]; then
			tgt_orig="$(readlink $tgt_path)"
			tgt_orig="$(normalize_dir $tgt_orig)"
			if [ "$tgt_orig" == "$src_path" ]; then
				flog_log "$f is already symlinked to $src_path"
			elif [ "${tgt_orig#$DOTFILE_PATH}" == "$tgt_orig" ]; then
				flog_warn "$f is already symlinked to ${tgt_orig}."
				flog_warn "Not symlinking $src_path because $f is already symlinked to $tgt_orig."
			else
				flog_log "Updating symlink of $f to $src_path"
				rm "$tgt_path"
				ln -s "$src_path" "$tgt_path"
				flog_success "Symlinked $f to $src_path"
			fi
		elif [ -f "$tgt_path" ]; then
			flog_warn "A file already exists at $tgt_path."
			if flog_confirm "Replace with symlink to ${src_path}?"; then
				tgt_old_path="${tgt_path}.local"
				if [ -e "$tgt_old_path" ]; then
					flog_warn "$tgt_old_path exists as well! Move or remove it first."
				else
					mv "$tgt_path" "$tgt_old_path"
					flog_success "Moved old $tgt_path to $tgt_old_path"
					ln -s "$src_path" "$tgt_path"
					flog_success "Symlinked $f to $src_path"
				fi
			fi
		else
			ln -s "$src_path" "$tgt_path"
			flog_success "Symlinked $f to $src_path"
		fi
	done
}
