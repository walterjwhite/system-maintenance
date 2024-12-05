_patch_freebsd() {
	_ freebsd-update $_FREEBSD_UPDATE_OPTIONS install

	if [ $? -eq 2 ]; then
		_warn "no updates available, fetch first"
		return
	fi

	_REBOOT_REQUIRED="FreeBSD updated"
	_CHECK_RESTART=1
}

_patch_freebsd_upgrade() {
	_patch_freebsd_upgrade_do upgrade install
}

_patch_freebsd_upgrade_install() {
	_patch_freebsd_upgrade_do install kernel
}

_patch_freebsd_upgrade_kernel() {
	_patch_kernel
}

_patch_freebsd_upgrade_do() {
	_require "$_PATCH_ARGUMENTS" _PATCH_ARGUMENTS

	_ freebsd-update $_FREEBSD_UPDATE_OPTIONS $1 -r $_PATCH_ARGUMENTS

	if [ $? -eq 2 ]; then
		_warn "no upgrades available"
		return
	fi

	_REBOOT_REQUIRED="FreeBSD Upgrade ${1}ed"
	_CHECK_RESTART=0

	_PATCH_FNCTN="$_PATCH_FNCTN|_patch_freebsd_upgrade_$1"
	_patch_be
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

	_ git reset --hard HEAD

	local system_version=$(uname -r | sed -e 's/-RELEASE.*//')
	_ git checkout releng/$system_version
	_ git pull

	KERNCONF=custom
	_ make buildkernel && make installkernel

	_info "Rebuilt kernel, please reboot to use patched kernel"
	_REBOOT_REQUIRED="Kernel updated"
}
