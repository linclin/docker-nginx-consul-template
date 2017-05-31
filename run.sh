#!/bin/sh

if [ -z "$CONSUL_ADDR" ]
then
    echo "CONSUL_ADDR must be set"
    exit 1;
fi;

CONSUL_PORT=${CONSUL_PORT:-8500}

exec nohup consul-template -consul-addr="$CONSUL_ADDR:$CONSUL_PORT" -consul-retry  -consul-retry-attempts=5 -wait=5s -template="/app/nginx.ctmpl:/etc/nginx/conf.d/default.conf:nginx -s reload" >> /tmp/consul-template.log &
exec nginx -g "daemon off;" 
