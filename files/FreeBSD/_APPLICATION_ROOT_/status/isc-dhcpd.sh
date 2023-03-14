# this checks the previous log for 'no free leases'
_ISC_DHCPD_LOG_FILE=/var/log/dhcpd/log.0.zst

_isc_dhcpd() {
	if [ ! -e /var/log/dhcpd ]; then
		_warn 'ISC DHCPD not detected, aborting'
		return
	fi

	_isc_dhcpd_no_free_leases
	_isc_dhcpd_other_errors
}

_isc_dhcpd_no_free_leases() {
	_isc_dhcpd_has_no_free_leases || return

	local message
	local dhcp_device
	local instance
	for dhcp_device in $(zstdgrep 'no free leases' $_ISC_DHCPD_LOG_FILE | awk {'print$9'} | sort -u); do
		instance=$(zstdgrep $dhcp_device $_ISC_DHCPD_LOG_FILE | awk {'printf "%-12s %-17s %s %s %s\n", $7, $9, $1, $2, $3'} | sed -e s/^$dhcp_device\ //)

		if [ -n "$message" ]; then
			message="$message\n$instance"
		else
			message="$instance"
		fi
	done

	[ "$message" ] && _STATUS_MESSAGE="$_STATUS_MESSAGE\n\nISC DHCPd - no free leases\n$message"
}

_isc_dhcpd_has_no_free_leases() {
	zstdgrep 'no free leases' $_ISC_DHCPD_LOG_FILE >/dev/null 2>&1
}

_isc_dhcpd_other_errors() {
	_isc_dhcpd_has_other_errors || return

	local message
	local dhcp_error
	for dhcp_error in $(zstdgrep -i err $_ISC_DHCPD_LOG_FILE | $_CONF_INSTALL_GNU_GREP -Pv '(DHCPDISCOVER|last message repeated)' |
		sed -e 's/.*\://' | sed -e 's/^ //' | sort -u); do
		instance=$(zstdgrep "$dhcp_error" $_ISC_DHCPD_LOG_FILE | sed -e 's/^.*.zst://' | awk {'printf "$dhcp_error %s %s %s\n", $1, $2, $3'})

		if [ -n "$message" ]; then
			message="$message\n$instance"
		else
			message="$instance"
		fi
	done

	[ "$message" ] && _STATUS_MESSAGE="$_STATUS_MESSAGE\n\nISC DHCPd - other errors\n$message"
}

_isc_dhcpd_has_other_errors() {
	zstdgrep -i err $_ISC_DHCPD_LOG_FILE | $_CONF_INSTALL_GNU_GREP -Pv '(DHCPDISCOVER|last message repeated)' >/dev/null 2>&1
}
