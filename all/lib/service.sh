_disable_service() {
	SERVICE_ACTION=stop SERVICE_ENABLED=NO _service "$@"
}

_enable_service() {
	SERVICE_ACTION=start SERVICE_ENABLED=YES _service "$@"
}

_service() {
	local service
	for service in "$@"; do
		if [ -z "$_CONF_FREEBSD_INSTALLER_SYSTEM_BRANCH" ]; then
			service $service one${SERVICE_ACTION}
		fi

		sysrc ${service}_enable=${SERVICE_ENABLED}
	done
}
