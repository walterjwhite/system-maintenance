_system_alert() {
	local system=$(head -1 /usr/local/etc/walterjwhite/system)

	local message=$(printf '%s\n%s\n' "$2")
	_alert "$system: $1" "$message"
}
