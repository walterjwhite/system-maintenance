# drop data > $_CONF_SYSTEM_MAINTENANCE_ELASTICSEARCH_RETENTION_PERIOD days in elasticsearch
_elasticsearch() {
	local index
	for index in $(curl $_CONF_SYSTEM_MAINTENANCE_ELASTICSEARCH_HOST/_cat/indices -H 'Content-Type: application/json' -s | awk {'print$3'} | grep -v '^\.'); do
		_elasticsearch_prune_old_data $index
	done
}

_elasticsearch_prune_old_data() {
	_info "Attempting to delete data > $_CONF_SYSTEM_MAINTENANCE_ELASTICSEARCH_RETENTION_PERIOD from $1"
	_ curl -s -X POST $_CONF_SYSTEM_MAINTENANCE_ELASTICSEARCH_HOST/$index/_delete_by_query -d"{\"query\": {\"range\": {\"@timestamp\": {\"lte\": \"now-$_CONF_SYSTEM_MAINTENANCE_ELASTICSEARCH_RETENTION_PERIOD\"}}}}" -H 'Content-Type: application/json'
}
