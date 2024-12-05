_get_jail_volumes() {
	grep 'path = ' /etc/jail.conf /etc/jail.conf.d -rh 2>/dev/null | awk -F'=' {'print$2'} | tr -d ' ;"' | sed -e 's/^\///' | sort -u
}

_in_jail() {
	if [ $(sysctl -n security.jail.jailed) -eq 1 ]; then
		return 0
	fi

	return 1
}
