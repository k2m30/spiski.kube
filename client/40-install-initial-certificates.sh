#!/bin/sh

domain=spiski.live
data_path="/etc/letsencrypt"
path="$data_path/live/$domain"

# Download TLS parameters if needed
if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf >"$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem >"$data_path/conf/ssl-dhparams.pem"
  echo
fi

# Generate initial dummy certificates if needed to start nginx
if [ ! -d $path ]; then
  echo
  echo "### Creating dummy certificate for $domain ..."
  echo

  mkdir -p $path

  openssl req -x509 -nodes -newkey rsa:4096 -days 1 \
    -keyout "$path/privkey.pem" \
    -out "$path/fullchain.pem" \
    -subj "/CN=localhost"

  echo
  echo "### Replace dummy certificates with certbot in 1 min"
  echo

  # Replace dummy certificates with certbot
  sleep 1m &&
    rm -rf $path &&
    certbot certonly --webroot --webroot-path="$data_path/challenges" --rsa-key-size 4096 --email 1m@tut.by --agree-tos --no-eff-email -d $domain &&
    nginx -s reload \
    &

fi

echo
echo "### Renewals every 12h"
echo

while :; do
  sleep 12h &
  wait ${!}
  certbot renew && nginx -s reload
done &
