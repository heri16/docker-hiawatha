# Hiawatha Docker Container

[![](https://img.shields.io/docker/automated/heri16/hiawatha.svg)](https://hub.docker.com/r/heri16/hiawatha/ "Docker Hub")
[![](https://images.microbadger.com/badges/image/heri16/hiawatha.svg)](https://microbadger.com/images/heri16/hiawatha "Get your own image badge on microbadger.com")

This is a lightweight Docker container that provides the **[Hiawatha](http://www.hiawatha-webserver.org)** web server.

Usage is straightforward and relies only on a data volume mounted at */var/www*. There is a second volume for logging at */var/log/hiawatha*.

PHP is supported but is not built-in to the container. The startup script `run.sh` will make provision for linking to a PHP-FPM instance listening on port 9000. If this is not linked PHP scripts will not be intepreted.

### Minimal Example Usage:

    docker build -t heri16/hiawatha .
    mkdir www
    docker run -P --name web -v ./www/:/var/www -v ./hosts.conf:/etc/hiawatha/hosts.conf heri16/hiawatha

### Full Example usage:

    docker build -t heri16/hiawatha .
    mkdir www log
    docker run -d --name php-fpm php:fpm-alpine
    docker run -P --name web --link php-fpm:php -v ./www/:/var/www -v ./log:/var/log/hiawatha -v ./hosts.conf:/etc/hiawatha/hosts.conf -v ./toolkits.conf:/etc/hiawatha/toolkits.conf ./bindings.conf:/etc/hiawatha/bindings.conf heri16/hiawatha

### Example hosts.conf:

    VirtualHost {
        Hostname = example.com
        WebsiteRoot = /var/www/example.com/html
        StartFile = index.php
        AccessLogfile = /var/www/example.com/log/access.log
        ErrorLogfile = /var/www/example.com/log/error.log
        TimeForCGI = 180
        UseFastCGI = PHP
        UseToolkit = drupal
        PreventCSRF = prevent
        PreventSQLi = prevent
        PreventXSS = prevent
        RequireTLS = yes, 2678400
    }

### Example toolkits.conf:

    UrlToolkit {
        ToolkitID = drupal
        RequestURI isfile Return
        Match ^/favicon.ico$ Return
        Match /(.*)\?(.*) Rewrite /index.php?q=$1&$2
        Match /(.*) Rewrite /index.php?q=$1
    }

### Example bindings.conf:

    MinTLSversion = 1.2
    Binding {
        Port = 443
        TLScertFile = ssl/hiawatha.pem
        MaxRequestSize = 2048
        TimeForRequest = 30
    }

The above .conf include files ensure your hiawatha image will upgrade seamlessly when new versions of hiawatha is release.
Some basic configuration changes have also been made to *hiawatha.conf* to enhance security.

However, you can fully override /etc/hiawatha/hiawatha.conf if required:

    docker run -v ./hiawatha.conf:/etc/hiawatha/hiawatha.conf

See the complete reference for hiawatha.conf here:
**[Hiawatha Manpages](https://www.hiawatha-webserver.org/manpages/hiawatha/#index)**


## Docker compose

Using docker compose is optional, but the recommended way for painless multi-container Docker services.  

### Example docker-compose.yml:

    version: '2'
    services:
      php_fpm:
        build: ./php
        expose:
         - "9000"
        volumes:
          - /var/www/:/var/www:ro
      hiawatha_web:
        image: heri16/hiawatha
        links:
          - php_fpm:php
        environment:
          - PHP_HOST=php
          - PHP_FPM_PORT=9000
        ports:
          - "80:80"
          - "443:443"
        volumes:
          - /home/centos/piler/hosts.conf:/etc/hiawatha/hosts.conf:ro,Z
