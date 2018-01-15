#!/bin/bash
/proxy-conf/config.sh > /etc/nginx/nginx.conf && nginx -g "daemon off;"