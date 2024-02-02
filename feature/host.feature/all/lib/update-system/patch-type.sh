_patch_freebsd() {
	_ freebsd-update $_FREEBSD_UPDATE_OPTIONS install

	if [ $? -eq 2 ]; then
		_warn "no updates available, fetch first"
		return
	fi

	_REBOOT_REQUIRED="FreeBSD updated"
	_CHECK_RESTART=1
}

_patch_userland() {
	_ pkg $_PKG_UPDATE_OPTIONS upgrade -y
	_CHECK_RESTART=1
}

_patch_kernel() {
	if [ -n "$_ON_JAIL" ]; then
		_error "Cannot update kernel for jail - $_JAIL_NAME"
	fi

	cd /usr/src

	_ git pull

	KERNCONF=custom
	_ make buildkernel && make installkernel

	_info "Rebuilt kernel, please reboot to use patched kernel"
	_REBOOT_REQUIRED="Kernel updated"
}
