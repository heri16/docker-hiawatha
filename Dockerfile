FROM debian:wheezy
MAINTAINER Heri Sim <heri16@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ADD http://http.debian.net/debian/project/trace/ftp-master.debian.org /etc/trace_ftp-master.debian.org
ADD http://security.debian.org/project/trace/security-master.debian.org /etc/trace_security-master.debian.org

RUN apt-key adv --recv-keys --keyserver keys.gnupg.net DC242980 && \
    echo 'deb http://apt.sparkz.no/debian/ squeeze main' > /etc/apt/sources.list.d/hiawatha.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install hiawatha

#ADD hiawatha.conf /etc/hiawatha/hiawatha.conf
RUN sed -i -e"s/^\#\(\s*\(BanOnGarbage\|BanOnMaxPerIP\|BanOnMaxReqSize\|KickOnBan\|RebanDuringBan\).*\)/\1/" /etc/hiawatha/hiawatha.conf

RUN echo "# Replace this config file via Docker's --volumes-from or -v ./toolkits.conf:/etc/hiawatha/toolkits.conf" > /etc/hiawatha/toolkits.conf
RUN sed -i -e"s/^\#UrlToolkit {$/Include \/etc\/hiawatha\/toolkits.conf\n#UrlToolkit {/" /etc/hiawatha/hiawatha.conf
RUN echo "# Replace this config file via Docker's --volumes-from or -v ./hosts.conf:/etc/hiawatha/hosts.conf" > /etc/hiawatha/hosts.conf
RUN sed -i -e"s/^\#VirtualHost {$/Include \/etc\/hiawatha\/hosts.conf\n#VirtualHost {/" /etc/hiawatha/hiawatha.conf

ADD run.sh /sbin/run-hiawatha.sh

VOLUME /var/log/hiawatha
VOLUME /var/www

EXPOSE 80

CMD ["/sbin/run-hiawatha.sh"]
