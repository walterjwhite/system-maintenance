_checkrestart() {
	_info "checkrestart - start"
	_ checkrestart -H $_CHECKRESTART_OPTIONS

	local service_options
	if [ -n "$_JAIL_NAME" ]; then
		service_options="-j $_JAIL_NAME"
	fi

	local check_restart_service
	for check_restart_service in $(checkrestart -H $_CHECKRESTART_OPTIONS | awk {'print$3'}); do
		service $service_options $check_restart_service restart
	done

	if [ $(checkrestart -H $_CHECKRESTART_OPTIONS | wc -l) -gt 0 ]; then
		_warn "checkrestart - restart system / services *REQUIRED*"
		_REBOOT_REQUIRED=$(printf 'checkrestart - restart system / services *REQUIRED*\n%s\n%s\n' "checkrestart -H $_CHECKRESTART_OPTIONS" "$(checkrestart -H $_CHECKRESTART_OPTIONS)")
		_do_reboot
	fi
}

_was_latest_patch_applied() {
	if [ $(wc -l $_LAST_SEQUENCE_FILE | awk '{print$1}') -gt 1 ]; then
		_info "latest patch already applied"
		return 0
	fi

	return 1
}

_apply_patch() {
	_info "applying patch: $_LAST_SEQUENCE"

	if [ ! -e $_LAST_SEQUENCE_FILE ]; then
		_error "$_LAST_SEQUENCE_FILE does not exist"
	fi

	_SYSTEM_BE_WITH_SEQUENCE="$_SYSTEM_BE.$_LAST_SEQUENCE"
	_PATCH_FNCTN=$(head -1 $_LAST_SEQUENCE_FILE)
	_PATCH_ARGUMENTS=$(printf '%s' "$_PATCH_FNCTN" | cut -f2 -d'|' -s)

	if [ -n "$_PATCH_ARGUMENTS" ]; then
		_PATCH_FNCTN=$(printf '%s' "$_PATCH_FNCTN" | cut -f1 -d'|' -s)
	fi

	if [ -z "$_JAIL_PATH" ]; then
		if [ "$_ACTIVE_BE" != "$_SYSTEM_BE_WITH_SEQUENCE" ]; then
			_error "reboot into latest BE: $_ACTIVE_BE ($_SYSTEM_BE_WITH_SEQUENCE) before applying patches [$_PATCH_FNCTN]"
		fi
	else
		_warn "no need to reboot, patching jail: $_JAIL_PATH"
	fi

	_info "applying patches, BE: $_SYSTEM_BE_WITH_SEQUENCE [$_PATCH_FNCTN]"
	_patch_$_PATCH_FNCTN

	if [ -n "$_DRY_RUN" ]; then
		_info "date >>$_LAST_SEQUENCE_FILE"
	else
		date >>$_LAST_SEQUENCE_FILE
	fi

	if [ -n "$_CHECK_RESTART" ]; then
		_checkrestart
	fi

	_do_reboot
}
