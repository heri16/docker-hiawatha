#!/bin/sh
set -e

if [ -n "${PHP_HOST+1}" ] && [ -n "${PHP_FPM_PORT+1}" ]; then
    sed -i -e"s/\(FastCGIid\s=\).*$/\1 PHP/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/\(Extension\s=\).*$/\1 php/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/\(ConnectTo\s=\).*$/\1 ${PHP_HOST}:${PHP_PORT}/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/^\#\(\s*\(FastCGIserver\|FastCGIid\|ConnectTo\).*\)/\1/" -e"s/^\#\(\s*Extension.*\)/\1\n\}/" /etc/hiawatha/hiawatha.conf
elif [ -n "${PHP_PORT_9000_TCP_ADDR+1}" ] && [ -n "${PHP_PORT_9000_TCP_PORT+1}" ]; then
    sed -i -e"s/\(FastCGIid\s=\).*$/\1 PHP/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/\(Extension\s=\).*$/\1 php/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/\(ConnectTo\s=\).*$/\1 ${PHP_PORT_9000_TCP_ADDR}:${PHP_PORT_9000_TCP_PORT}/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/^\#\(\s*\(FastCGIserver\|FastCGIid\|ConnectTo\).*\)/\1/" -e"s/^\#\(\s*Extension.*\)/\1\n\}/" /etc/hiawatha/hiawatha.conf
fi

exec /usr/sbin/hiawatha -d
