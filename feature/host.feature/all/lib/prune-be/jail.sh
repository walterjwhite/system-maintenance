import jail.sh
import feature/zfs.feature/zfs.sh

_prune_jail_snapshot_destroy() {
	_warn "destroying Jail Snapshot $_JAIL_ZFS_SNAPSHOT - created $_ZFS_SNAPSHOT_CR_DT ($_ZFS_SNAPSHOT_AGE_HUMAN)"
	$_SUDO_CMD zfs destroy $_JAIL_ZFS_SNAPSHOT
}

_prune_jail_snapshot_by_age() {
	_info "Pruning jail snapshots by age"

	for _JAIL_VOLUME in $(_get_jail_volumes); do
		_info "Pruning jail snapshots for: $_JAIL_VOLUME"
		for _JAIL_ZFS_SNAPSHOT in $(zfs list -H -t snapshot -o name $_JAIL_VOLUME); do
			_zfs_snapshot_details

			if [ $_ZFS_SNAPSHOT_AGE -gt $_CONF_SYSTEM_MAINTENANCE_JAIL_SNAPSHOT_EXPIRATION_PERIOD ]; then
				_prune_jail_snapshot_destroy
			else
				_debug "retaining snapshot: $_JAIL_ZFS_SNAPSHOT $_ZFS_SNAPSHOT_CR_DT $_ZFS_SNAPSHOT_AGE_HUMAN"
			fi

			_jail_snapshot_cleanup
		done
	done
}

_prune_jail_snapshot_by_number() {
	if [ -z "$_CONF_SYSTEM_MAINTENANCE_MAX_JAIL_SNAPSHOT_TO_KEEP" ]; then
		return 1
	fi

	_info "Pruning jail snapshots by count"
	for _JAIL_VOLUME in $(_get_jail_volumes); do
		_info "Pruning jail snapshots for: $_JAIL_VOLUME"
		for _JAIL_ZFS_SNAPSHOT in $(zfs list -H -t snapshot -o name $_JAIL_VOLUME | tail -r | tail -n +$_CONF_SYSTEM_MAINTENANCE_MAX_JAIL_SNAPSHOT_TO_KEEP | tail -r); do
			_zfs_snapshot_details
			_prune_jail_snapshot_destroy

			_jail_snapshot_cleanup
		done
	done
}

_jail_snapshot_cleanup() {
	unset _JAIL_ZFS_SNAPSHOT _ZFS_SNAPSHOT_CR_DT _ZFS_SNAPSHOT_AGE _ZFS_SNAPSHOT_AGE_HUMAN
}
