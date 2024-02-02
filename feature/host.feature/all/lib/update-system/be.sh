_be() {
	unset _SYSTEM_CONFIGURATION_FILE _PATCHES _SYSTEM_BRANCH _SYSTEM_HASH _SYSTEM_BE _SYSTEM_BE_WITH_SEQUENCE _ACTIVE_BE _LAST_SEQUENCE_FILE _LAST_SEQUENCE

	_SYSTEM_CONFIGURATION_FILE=$_JAIL_PATH/usr/local/etc/walterjwhite/system
	_PATCHES=$_JAIL_PATH/usr/local/etc/walterjwhite/patches

	_SYSTEM_BRANCH=$(head -1 $_SYSTEM_CONFIGURATION_FILE | tr '/' '_')
	_SYSTEM_HASH=$(grep commit $_SYSTEM_CONFIGURATION_FILE | awk {'print$2'} | cut -c 1-8)

	_SYSTEM_BE=${_SYSTEM_HASH}.${_SYSTEM_BRANCH}
	_SYSTEM_BE_WITH_SEQUENCE=$_SYSTEM_BE

	if [ -n "$_JAIL_NAME" ]; then
		_ACTIVE_BE=$(zfs list -H -t snapshot $_JAIL_PATH | tail -1 | awk {'print$1'})
	else
		_ACTIVE_BE=$(beadm list -H | grep NR | awk {'print$1'})
	fi

	if [ -z "$_JAIL_NAME" ]; then
		if [ -z "$_ACTIVE_BE" ]; then
			_system_alert "reboot into latest BE: $_SYSTEM_BE"
			_error "reboot into latest BE: $_SYSTEM_BE"
		fi
	fi

	mkdir -p /usr/local/etc/walterjwhite/patches $_JAIL_PATH/usr/local/etc/walterjwhite/patches
	_LAST_SEQUENCE_FILE=$(find $_JAIL_PATH/usr/local/etc/walterjwhite/patches -type f | sort -n | tail -1)
	if [ -n "$_LAST_SEQUENCE_FILE" ]; then
		_LAST_SEQUENCE=$(basename $_LAST_SEQUENCE_FILE)
		_SYSTEM_BE_WITH_SEQUENCE="$_SYSTEM_BE.$_LAST_SEQUENCE"
	else
		_LAST_SEQUENCE=000
		_LAST_SEQUENCE_FILE=$_JAIL_PATH/usr/local/etc/walterjwhite/patches/$_LAST_SEQUENCE
		_SYSTEM_BE_WITH_SEQUENCE="$_SYSTEM_BE.$_LAST_SEQUENCE"

		_FIRST_BOOT=1 _create_be $_SYSTEM_BE_WITH_SEQUENCE
	fi
}
