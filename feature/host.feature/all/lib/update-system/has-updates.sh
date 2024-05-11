_has_freebsd_updates() {
	_PATCH_FNCTN=freebsd

	PAGER=cat
	_ freebsd-update $_FREEBSD_UPDATE_OPTIONS --not-running-from-cron fetch

	_WARN_ON_ERROR=1 _ freebsd-update $_FREEBSD_UPDATE_OPTIONS updatesready
	if [ $? -eq 2 ]; then
		return 1
	fi

	return 0
}

_has_userland_updates() {
	_PATCH_FNCTN=userland

	_ pkg $_PKG_UPDATE_OPTIONS update
	_WARN_ON_ERROR=1 _ pkg $_PKG_UPDATE_OPTIONS upgrade -n
	if [ $? -eq 0 ]; then
		return 1
	fi

	_ pkg $_PKG_UPDATE_OPTIONS upgrade -Fy
	return 0
}

_has_kernel_updates() {
	_PATCH_FNCTN=kernel

	cd /usr/src

	local kernel_git_branch=$(git branch --no-color --show-current)
	_require "$kernel_git_branch" kernel_git_branch

	_LATEST_REMOTE_VERSION=$(git ls-remote $(git remote -v | head -1 | awk {'print$2'}) | grep $kernel_git_branch | cut -f1)
	_LATEST_LOCAL_VERSION=$(git rev-parse HEAD)

	if [ "$_LATEST_REMOTE_VERSION" = "$_LATEST_LOCAL_VERSION" ]; then
		return 1
	fi

	return 0
}

_patch_be() {
	_info "$_PATCH_FNCTN updates available"

	if [ -z "$_LAST_SEQUENCE" ]; then
		_LAST_SEQUENCE=$(seq -w 0 1 $_CONF_SYSTEM_MAINTENANCE_MAX_PATCHES | head -1)
	else
		_LAST_SEQUENCE=$(seq -w $_LAST_SEQUENCE 1 $_CONF_SYSTEM_MAINTENANCE_MAX_PATCHES | sed 1d | head -1)
	fi

	_SYSTEM_BE_WITH_SEQUENCE="$_SYSTEM_BE.$_LAST_SEQUENCE"

	_LAST_SEQUENCE_FILE=$_JAIL_PATH/usr/local/etc/walterjwhite/patches/$_LAST_SEQUENCE
	if [ -n "$_DRY_RUN" ]; then
		_info "printf '%s\n' \"$_PATCH_FNCTN\" > $_LAST_SEQUENCE_FILE"
	else
		printf '%s\n' "$_PATCH_FNCTN" >$_LAST_SEQUENCE_FILE
	fi

	_create_be $_SYSTEM_BE_WITH_SEQUENCE
}
