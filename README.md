# Docker.AsIKnow.Proxy
Nginx based reverse proxy

CFG\_SERVER\_PROP\__propname_ will be inserted as _propname_ _value_; in nginx server config
CFG\LISTEN would be the nginx listening port.
CFG\_PORTS is a comma separated list of proxied ports (eg.: 80,8080,5000)
CFG\_HOSTS is a comma separated list of proxied hosts (eg.: host1, host2,host3)
CFG\_PATHS is a comma separated list of path override (eg.: /svc1,/test/svc1:/api,!/api, which means: on /svc1 proxy host1:80/, on /test/svc1 proxy host2:8080/api, block host3:5000/api)
