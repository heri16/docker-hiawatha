#!/bin/sh
set -e

# Detect and Enable PHP-FPM
if [ -n "${PHP_HOST+1}" ] && [ -n "${PHP_FPM_PORT+1}" ]; then
    PHP_HOST_IP="$(getent hosts ${PHP_HOST} | awk '{ print $1 }')"
    sed -i -e"s/\(FastCGIid\s=\).*$/\1 PHP/" -e"s/\(Extension\s=\).*$/\1 php/" -e"s/\(ConnectTo\s=\).*$/\1 ${PHP_HOST_IP}:${PHP_FPM_PORT}/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/^\#\(\s*\(FastCGIserver\|FastCGIid\|ConnectTo\).*\)/\1/" -e"s/^\#\(\s*Extension.*\)/\1\n\}/" /etc/hiawatha/hiawatha.conf
elif [ -n "${PHP_PORT_9000_TCP_ADDR+1}" ] && [ -n "${PHP_PORT_9000_TCP_PORT+1}" ]; then
    sed -i -e"s/\(FastCGIid\s=\).*$/\1 PHP/" -e"s/\(Extension\s=\).*$/\1 php/" -e"s/\(ConnectTo\s=\).*$/\1 ${PHP_PORT_9000_TCP_ADDR}:${PHP_PORT_9000_TCP_PORT}/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/^\#\(\s*\(FastCGIserver\|FastCGIid\|ConnectTo\).*\)/\1/" -e"s/^\#\(\s*Extension.*\)/\1\n\}/" /etc/hiawatha/hiawatha.conf
fi

# Generate Default Self-signed TLS Cert (if missing)
if [ ! -f /etc/hiawatha/tls/selfcertwithkey.pem ]; then
  (mkdir /etc/hiawatha/tls || true && cd /etc/hiawatha/tls && \
  /usr/libexec/mbedtls/gen_key type=rsa rsa_keysize=4096 filename=privkey.pem && \
  /usr/libexec/mbedtls/cert_write selfsign=1 issuer_key=privkey.pem issuer_name=CN=myserver,O=myorganisation,C=US is_ca=1 max_pathlen=0 output_file=selfcert.pem && \
  cat privkey.pem selfcert.pem > selfcertwithkey.pem) || true
fi

exec /usr/sbin/hiawatha -d
