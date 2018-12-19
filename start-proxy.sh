#!/bin/bash

onlyHostname() {
    echo $1 | awk -F':' '{print $1}'
}

toLowerCase() {
    echo $1 | awk '{print tolower($0)}'
}

GATEWAY=${GATEWAY:-"gateway:8080"}
SERVICES=${@}
locations=''

gateway_host=$(onlyHostname $GATEWAY)
gateway_lower=$(toLowerCase $GATEWAY)
locations+=$"location / {proxy_pass      http://${gateway_lower};}"

for service in $SERVICES; do
    service_host=$(onlyHostname $service | sed s/-app//)
    service_host_lower=$(toLowerCase $service_host)
    service_lower=$(toLowerCase $service)
    locations+=$"location /${service_host_lower}/ {proxy_pass      http://${service_lower}/$service_host/;}"
done;

locations=$(echo $locations | sed -e 's/[\/&]/\\&/g')
sed -e "s/LOCATIONS/$locations/g" nginx.conf.tpl  > /etc/nginx/nginx.conf
echo 'Starting nginx proxy with this config:'
echo '=== NGINX.CONF BEGIN ==='
cat /etc/nginx/nginx.conf
echo '=== NGINX.CONF END ==='
nginx -g "daemon off;"
