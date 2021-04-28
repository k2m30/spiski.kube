FROM nginx:1.19-alpine
RUN apk add --no-cache \
    curl \
    openssl

COPY default.conf /etc/nginx/conf.d/
COPY 40-install-initial-certificates.sh /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/40-install-initial-certificates.sh