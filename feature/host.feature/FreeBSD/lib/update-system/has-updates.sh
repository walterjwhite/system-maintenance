_has_freebsd_updates() {
	_PATCH_FNCTN=freebsd

	PAGER=cat
	_ freebsd-update $_FREEBSD_UPDATE_OPTIONS --not-running-from-cron fetch

	_WARN_ON_ERROR=1 _ freebsd-update $_FREEBSD_UPDATE_OPTIONS updatesready
	[ $? -eq 2 ] && return 1

	return 0
}

_has_freebsd_upgrade_updates() {
	_PATCH_FNCTN=freebsd_upgrade

	local fbsd_architecture=$(uname -p)
	_require "$fbsd_architecture" fbsd_architecture

	local fbsd_current_version=$(uname -r | grep -E -o '[[:digit:],\.]{4,}')
	_require "$fbsd_current_version" fbsd_current_version

	local fbsd_current_integer_version=$(printf '%s' "$fbsd_current_version" | sed s/[.]//)

	local fbsd_url="https://download.freebsd.org/releases/$fbsd_architecture/"
	local fbsd_lines=$(curl --silent $fbsd_url)
	if [ $? -ne 0 ]; then
		_warn "error downloading release page"
		return 1
	fi

	local fbsd_versions=$(printf '%s' "$fbsd_lines" | grep -o -E '[[:digit:]]{2}\.[[:digit:]]{1}-[[:alpha:]]{4,}' | grep -v 'BETA$' | sort -u)
	local fbsd_version

	for fbsd_version in $(printf '%s' "$fbsd_versions"); do
		local fbsd_integer_version=$(echo "$fbsd_version" | sed s/[[:alpha:],.-]//g)
		[ "$fbsd_integer_version" -gt "$fbsd_current_integer_version" ] && {
			_detail "available version: $fbsd_version"
			return 0
		}
	done

	local latest_version=$(curl -s https://download.freebsd.org/releases/amd64/ | awk '{print $3}' | grep RELEASE | tr -d '"' | tr -d '/' | cut -f2 -d'=' | sort | tail -1)
	local system_version=$(freebsd-version | /usr/local/bin/grep -Po '[\d\.]{1,}(-RELEASE)')

	[ "$latest_version" == "$system_version" ] && return 1

	local version_shortname=$(printf '%s' "$latest_version" | sed -e 's/-RELEASE.*$/R/')
	curl -f "https://www.freebsd.org/releases/$version_shortname/announce.asc" > /dev/null 2>&1
	[ $? -eq 22 ] && {
		_warn "Release $latest_version is not yet ready"
		return 1
	}

	_PATCH_FNCTN="$_PATCH_FNCTN|$latest_version"

	return 0
}

_has_userland_updates() {
	_PATCH_FNCTN=userland

	_ pkg $_PKG_UPDATE_OPTIONS update
	_WARN_ON_ERROR=1 _ pkg $_PKG_UPDATE_OPTIONS upgrade -n
	[ $? -eq 0 ] && return 1

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

	[ "$_LATEST_REMOTE_VERSION" = "$_LATEST_LOCAL_VERSION" ] && return 1

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
