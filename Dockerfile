FROM alpine:latest
MAINTAINER Heri Sim <heri16@gmail.com>

RUN apk update \
    && apk upgrade \
    && apk add curl mbedtls mbedtls-static mbedtls-utils mbedtls-dev --update-cache --repository http://dl-8.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
    && apk add hiawatha hiawatha-doc --update-cache --repository http://dl-8.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

RUN sed -i -e"s/^\#\(\s*\(BanOnGarbage\|BanOnMaxPerIP\|BanOnMaxReqSize\|KickOnBan\|RebanDuringBan\).*\)/\1/" /etc/hiawatha/hiawatha.conf && \
    echo "# Replace this config file via Docker's --volumes-from or -v ./bindings.conf:/etc/hiawatha/bindings.conf" > /etc/hiawatha/bindings.conf && \
    sed -i -e"s/^\#Binding {$/Include \/etc\/hiawatha\/bindings.conf\n#Binding {/" /etc/hiawatha/hiawatha.conf && \
    echo "# Replace this config file via Docker's --volumes-from or -v ./toolkits.conf:/etc/hiawatha/toolkits.conf" > /etc/hiawatha/toolkits.conf && \
    sed -i -e"s/^\#UrlToolkit {$/Include \/etc\/hiawatha\/toolkits.conf\n#UrlToolkit {/" /etc/hiawatha/hiawatha.conf && \
    echo "# Replace this config file via Docker's --volumes-from or -v ./hosts.conf:/etc/hiawatha/hosts.conf" > /etc/hiawatha/hosts.conf && \
    sed -i -e"s/^\#VirtualHost {$/Include \/etc\/hiawatha\/hosts.conf\n#VirtualHost {/" /etc/hiawatha/hiawatha.conf

EXPOSE 80/tcp 443/tcp

#VOLUME ["/etc/hiawatha", "/var/log/hiawatha", "/var/www/hiawatha"]

ADD run.sh /sbin/run-hiawatha.sh

CMD ["/sbin/run-hiawatha.sh"]
