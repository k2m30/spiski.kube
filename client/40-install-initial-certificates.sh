#!/bin/sh

domain=docker.spiski.live
data_path="/etc/letsencrypt"

# Download TLS parameters if needed
if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf >"$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem >"$data_path/conf/ssl-dhparams.pem"
  echo
fi

# Generate initial certificates if needed
if [ ! -d "$data_path/live/$domain" ]; then

  echo "### Creating dummy certificate for $domain ..."
  mkdir -p "$data_path/live/$domain"
  path="$data_path/live/$domain"

  openssl req -x509 -nodes -newkey rsa:4096 -days 1\
    -keyout "$path/privkey.pem" \
    -out "$path/fullchain.pem" \
    -subj "/CN=localhost"
fi

