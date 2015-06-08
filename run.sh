#!/bin/sh

if [ -z "$FPM_PORT_9000" ]; then
    sed -i -e"s/^\#\(\s*\(FastCGIserver\|FastCGIid\|ConnectTo\).*\)/\1/" -e"s/^\#\(\s*Extension.*\)/\1\n\}/" /etc/hiawatha/hiawatha.conf
    sed -i -e"s/\(ConnectTo\s=\).*$/\1 $FPM_PORT_9000_TCP_ADDR:$FPM_PORT_9000_TCP_PORT/" /etc/hiawatha/hiawatha.conf
fi

exec /usr/sbin/hiawatha -d
