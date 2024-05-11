_do_reboot() {
	if [ -n "$_REBOOT_REQUIRED" ]; then
		_system_alert "reboot is required" "$_REBOOT_REQUIRED"

		if [ $_CONF_SYSTEM_MAINTENANCE_REBOOT -eq 1 ] || [ -n "$_FIRST_BOOT" ]; then
			if [ -n "$_ON_JAIL" ]; then
				service jail restart $_JAIL_NAME
			else
				_ reboot
			fi
		else
			_warn "not rebooting - $_CONF_SYSTEM_MAINTENANCE_REBOOT"
			_success "please reboot to install updates [$_REBOOT_REQUIRED]"
		fi
	fi

	unset _REBOOT_REQUIRED
}

_create_be() {
	if [ -n "$_ON_JAIL" ]; then
		_create_be_jail "$1"
		return
	fi

	_create_be_physical "$1"
}

_create_be_jail() {
	local target_jail_snapshot=$_JAIL_VOLUME@$1

	local latest_jail_snapshot=$(zfs list -H -t snapshot $_JAIL_VOLUME | tail -1 | awk {'print$1'})
	if [ "$latest_jail_snapshot" = "$target_jail_snapshot" ]; then
		_info "jail snapshot ($target_jail_snapshot) already exists"
		return
	fi

	_ zfs snapshot $target_jail_snapshot

	if [ -n "$_FIRST_BOOT" ]; then
		_warn "initializing patch sequence: $_LAST_SEQUENCE_FILE"
		printf 'create-be\n' >$_LAST_SEQUENCE_FILE
		printf '%s\n' "$(date)" >>$_LAST_SEQUENCE_FILE
	fi
}

_create_be_physical() {
	if [ $(beadm list -H | awk {'print$1'} | grep -c $1) -lt 1 ]; then
		if [ -n "$_FIRST_BOOT" ]; then
			_warn "initializing patch sequence: $_LAST_SEQUENCE_FILE"
			printf 'create-be\n' >$_LAST_SEQUENCE_FILE
			printf '%s\n' "$(date)" >>$_LAST_SEQUENCE_FILE

			_REBOOT_REQUIRED="First Boot, create BE"
		else
			_REBOOT_REQUIRED="$_PATCH_FNCTN updates available"
		fi

		local securelevel=$(sysrc kern_securelevel_enable | awk {'print$2'})
		if [ "$securelevel" = "YES" ]; then
			sysrc kern_securelevel_enable=NO
			_warn "TODO: Please run sysrc kern_securelevel_enable=YES to re-enable securelevel"
		fi

		_ beadm create $1
		_ beadm activate $1

		_do_reboot
	else
		_warn "BE: $1 already exists."
	fi
}
