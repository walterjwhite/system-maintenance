# @see: /etc/periodic/daily/480.status-ntpd
_ntp() {
	ntpq -pn 2>/dev/null | grep '^\*' || _STATUS_MESSAGE="NTP is not synchronized"
}
