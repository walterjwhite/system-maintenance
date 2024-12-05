_zfs_get_property() {
	zfs get -H $1 $2 | awk {'print$3'}
}

_zfs_snapshot_details() {
	_ZFS_SNAPSHOT_CR_DT=$(zfs get -H -p creation $_JAIL_ZFS_SNAPSHOT | awk {'print$3'})

	_ZFS_SNAPSHOT_AGE=$(($_CURRENT_EPOCH_TIME - $_ZFS_SNAPSHOT_CR_DT))

	_time_seconds_to_human_readable $_ZFS_SNAPSHOT_AGE
	_ZFS_SNAPSHOT_AGE_HUMAN=$_HUMAN_READABLE_TIME
	unset _HUMAN_READABLE_TIME
}

_zfs_is_volume_jailed() {
	local zfs_mount_point=$(zfs list -H $_ZFS_VOLUME | awk {'print$5'})
	if [ ! -e $zfs_mount_point ]; then
		_warn "$_ZFS_VOLUME appears to be jailed, skipping - $(zfs get -H jailed $_ZFS_VOLUME | awk {'print$3'}))"
		return 0
	fi

	return 1
}
