_wait_network() {
	ping -qo -i $_CONF_SYSTEM_MAINTENANCE_NETWORK_BACKOFF_TIME -c $_CONF_SYSTEM_MAINTENANCE_NETWORK_RETRIES $_CONF_SYSTEM_MAINTENANCE_NETWORK_TARGET >/dev/null 2>&1 && {
		_detail "Network is up"
		return
	}

	_error "Unable to get network connection"
}
