_get_jail_volumes() {
	grep path /etc/jail.conf /etc/jail.conf.d -rh 2>/dev/null | awk -F'=' {'print$2'} | tr -d ' ;"' | sed -e 's/^\///'
}

# if PID 1 exists, then we're either physical or virtualized, not jailed
_in_jail() {
	ps -p 1 >/dev/null 2>&1 || return 0

	return 1
}
