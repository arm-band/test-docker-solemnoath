#!/bin/bash

# gen key & certificate (Server Certificate)
openssl req -new -newkey rsa:2048 -nodes -out /etc/ssl/private/server.csr -keyout /etc/ssl/private/server.key -subj "/C=/ST=/L=/O=/OU=/CN=*.lvh.me"
openssl x509 -days 365 -req -signkey /etc/ssl/private/server.key -in /etc/ssl/private/server.csr -out /etc/ssl/private/server.crt

# gen key & certificate (Client Certificate)
echo "${7}" > /etc/ssl/private/CA/.cacn
echo "${8}" > /etc/ssl/private/CA/.capass
openssl genrsa -out  /etc/ssl/private/client.key 2048
openssl req -new -key /etc/ssl/private/client.key -out /etc/ssl/private/client.csr -passout file:/etc/ssl/private/CA/.capass -subj "/C=JP/ST=/L=/O=/OU=/CN=${7}"
openssl x509 -req -in /etc/ssl/private/client.csr -signkey /etc/ssl/private/client.key -days 3650 -out /etc/ssl/private/client.crt
cat /etc/ssl/private/client.key /etc/ssl/private/client.crt | openssl pkcs12 -password file:/etc/ssl/private/CA/.capass -export -out /etc/ssl/private/client.p12 -name "${7}"

# setting file replace and copy
sed -e "s/WEB_ROOT_DIRECTORY/${1}/gi" \
    -e "s/WEB_DOMAIN/${2}/gi" \
    -e "s/WEB_HOST_PORTNUM/${3}/gi" \
    -e "s/WEB_CONTAINER_PORTNUM/${4}/gi" \
    -e "s/WEB_HOST_PORTSSL/${5}/gi" \
    -e "s/WEB_CONTAINER_PORTSSL/${6}/gi" \
    /template/apache_vh.conf > /etc/httpd/conf.d/${1}.conf
sed -e "s/WEB_ROOT_DIRECTORY/${1}/gi" \
    -e "s/WEB_DOMAIN/${2}/gi" \
    -e "s/WEB_HOST_PORTNUM/${3}/gi" \
    -e "s/WEB_CONTAINER_PORTNUM/${4}/gi" \
    -e "s/WEB_HOST_PORTSSL/${5}/gi" \
    -e "s/WEB_CONTAINER_PORTSSL/${6}/gi" \
    -e "s/CA_CN/${7}/gi" \
    /template/apache_vh_ssl.conf > /etc/httpd/conf.d/${1}_ssl.conf

cp /template/php.conf /etc/httpd/conf.d/php.conf
cp /template/ssl.conf /etc/httpd/conf.d/ssl.conf
cp /template/index.php /var/www/${1}/web/index.php

# Apache start
/usr/sbin/httpd -DFOREGROUND &
