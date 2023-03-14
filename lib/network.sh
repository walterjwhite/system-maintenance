_wait_network() {
	while [ $_CONF_SYSTEM_MAINTENANCE_NETWORK_RETRIES -gt 0 ]; do
		dig $_CONF_SYSTEM_MAINTENANCE_NETWORK_TARGET >/dev/null 2>&1 && {
			_detail "Network is up"
			return
		}

		_CONF_SYSTEM_MAINTENANCE_NETWORK_RETRIES=$(($_CONF_SYSTEM_MAINTENANCE_NETWORK_RETRIES - 1))
		sleep $_CONF_SYSTEM_MAINTENANCE_NETWORK_BACKOFF_TIME
	done

	_error "Unable to get network connection"
}
