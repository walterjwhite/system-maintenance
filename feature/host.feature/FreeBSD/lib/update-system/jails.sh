import jail.sh

_patch_jails() {
	_LOGGING_CONTEXT=jail

	_info "inspecting jails"

	_ON_JAIL=1

	for _JAIL_VOLUME in $(_get_jail_volumes); do
		_JAIL_NAME=$(basename $_JAIL_VOLUME)
		_JAIL_PATH=/$_JAIL_VOLUME

		_LOGGING_CONTEXT=jail.$_JAIL_NAME
		_detail "inspecting jail"

		_FREEBSD_UPDATE_OPTIONS="-j $_JAIL_NAME"
		_PKG_UPDATE_OPTIONS="-j $_JAIL_NAME"
		_CHECKRESTART_OPTIONS="-j $_JAIL_NAME"

		_be

		_was_latest_patch_applied || _apply_patch

		_has_freebsd_updates && _patch_be && _apply_patch
		_has_freebsd_upgrade_updates && _patch_be && _apply_patch
		_has_userland_updates && _patch_be && _apply_patch

		_info "completed patching jail"
	done

	_info "no updates available"
}
