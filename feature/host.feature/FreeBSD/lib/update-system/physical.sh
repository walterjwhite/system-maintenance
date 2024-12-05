_patch_physical() {
	_LOGGING_CONTEXT=physical
	_be

	_wait_network
	_was_latest_patch_applied || _apply_patch

	_info "checking if additional updates are available"

	_has_freebsd_updates && _patch_be
	_has_freebsd_upgrade_updates && _patch_be
	_has_userland_updates && _patch_be
	_has_kernel_updates && _patch_be

	_info "no updates available"
}
