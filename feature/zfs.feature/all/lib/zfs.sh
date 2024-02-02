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
