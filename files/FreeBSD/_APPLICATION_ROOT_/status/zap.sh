import /lib/zfs.sh

# ensure that snapshots exist
_zap() {
	local message
	for _ZFS_VOLUME in $(zfs list -H | awk {'print$1'}); do
		local zap_managed=$(_zfs_get_property zap:snap $_ZFS_VOLUME | grep -c on)
		if [ "$zap_managed" -gt 0 ]; then
			_ZAP_BACKUP_SCHEDULE=$(_zfs_get_property zap:backup $_ZFS_VOLUME)

			local snapshot_age
			case $_ZAP_BACKUP_SCHEDULE in
			# if the interval matches the scheduled execution, then take a snapshot
			daily)
				snapshot_age=$((1 * 60 * 60 * 24))

				# allow some variance as periodic jobs do not run precisely on time
				# 8 hours
				snapshot_age=$(($snapshot_age + 8 * 60 * 60))
				;;
			weekly)
				snapshot_age=$((7 * 60 * 60 * 24))

				# allow some variance as periodic jobs do not run precisely on time
				# 1 day
				snapshot_age=$(($snapshot_age + 1 * 60 * 60 * 24))
				;;
			monthly)
				snapshot_age=$((30 * 60 * 60 * 24))

				# allow some variance as periodic jobs do not run precisely on time
				# 3 days
				snapshot_age=$(($snapshot_age + 3 * 60 * 60 * 24))
				;;
			*)
				continue
				;;
			esac

			# ensure the latest snapshot is <= max age
			local latest_snapshot=$(zfs list -t snapshot $_ZFS_VOLUME | tail -1 | awk {'print$1'})
			local latest_snapshot_date=$(zfs list -t snapshot $_ZFS_VOLUME | tail -1 | awk {'print$1'} | cut -f2 -d'@' | sed -e 's/.*_//' | sed -e 's/--.*//' | $_CONF_INSTALL_GNU_GREP -Po '[\d]{4}-[\d]{2}-[\d]{2}T[\d]{2}:[\d]{2}:[\d]{2}')

			local latest_snapshot_date_epoch=$(date -j -f '%Y-%m-%dT%H:%M:%S' "$latest_snapshot_date" +%s)
			local latest_snapshot_expiration=$(($latest_snapshot_date_epoch + $snapshot_age))
			local latest_snapshot_expiration_friendly=$(date -j -f '%s' $latest_snapshot_expiration "+$_CONF_INSTALL_DATE_FORMAT")
			local now=$(date +%s)

			local operator
			local level
			if [ $latest_snapshot_expiration -lt $now ]; then
				level=_system_alert
				operator='>'

				message="$message\nLatest snapshot ($latest_snapshot) [$_ZAP_BACKUP_SCHEDULE] $operator ($latest_snapshot_expiration_friendly)"
			fi
		fi
	done

	[ "$message" ] && _STATUS_MESSAGE="$message"
}
