_prune_be_destroy() {
	_warn "destroying BE $_BE_NAME - created $_BE_CR_DT ($_BE_AGE_HUMAN)"
	$_SUDO_CMD beadm destroy -F $_BE_NAME 2>&1 | sed -e 's/^/  /'
}

_prune_be_by_age() {
	local be_dtl=""
	beadm list -H | $_CONF_INSTALL_GNU_GREP -Pv '(N|R)' | while read be_dtl; do
		_prune_be_details

		if [ $_BE_AGE -gt $_CONF_SYSTEM_MAINTENANCE_BE_EXPIRATION_PERIOD ]; then
			_prune_be_destroy
		else
			_debug "retaining snapshot: $_BE_NAME $_BE_CR_DT $_BE_AGE_HUMAN"
		fi

		_be_cleanup
	done
}

_prune_be_by_number() {
	if [ -z "$_CONF_SYSTEM_MAINTENANCE_MAX_BE_TO_KEEP" ]; then
		return
	fi

	local be_dtl=""
	beadm list -H | $_CONF_INSTALL_GNU_GREP -Pv '^.*[\s]+(N|R)' | tail -r | tail -n +$_CONF_SYSTEM_MAINTENANCE_MAX_BE_TO_KEEP | tail -r | while read be_dtl; do
		_prune_be_details
		_prune_be_destroy

		_be_cleanup
	done
}

_prune_be_details() {
	_BE_NAME=$(printf '%s' "$be_dtl" | awk '{print$1}')
	_BE_CR_DT=$(printf '%s' "$be_dtl" | awk '{print$5" "$6}')
	local be_cr_dt_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S" "$_BE_CR_DT:00" "+%s")

	_BE_AGE=$(($_CURRENT_EPOCH_TIME - $be_cr_dt_epoch))

	_time_seconds_to_human_readable $_BE_AGE
	_BE_AGE_HUMAN=$_HUMAN_READABLE_TIME
	unset _HUMAN_READABLE_TIME
}

_be_cleanup() {
	unset _BE_NAME _BE_CR_DT _BE_AGE _BE_AGE_HUMAN
}
