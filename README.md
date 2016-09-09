# Hiawatha on Debian Wheezy

This is a Docker container that provides the **[Hiawatha](http://www.hiawatha-webserver.org)** web server.

Usage is straightforward and relies only on a data volume mounted at */var/www*. There is a second volume for logging at */var/log/hiawatha*.

PHP is supported but is not built-in to the container. The startup script `run.sh` will make provision for linking to a PHP-FPM instance listening on port 9000. If this is not linked PHP scripts will return a `503` error.

Minimal Example Usage:

    docker build -t heri16/hiawatha .
    mkdir www
    docker run -P --name web -v ./www:/var/www -v ./hosts.conf:/etc/hiawatha/hosts.conf heri16/hiawatha

Full Example usage:

    docker build -t heri16/hiawatha .
    mkdir www log 
    docker run -P --name web --link fpm:fpm -v ./www:/var/www -v ./log:/var/log/hiawatha -v ./hosts.conf:/etc/hiawatha/hosts.conf -v ./toolkits.conf:/etc/hiawatha/toolkits.conf ./bindings.conf:/etc/hiawatha/bindings.conf heri16/hiawatha

Example hosts.conf:

    VirtualHost {
        Hostname = example.com
        WebsiteRoot = /var/www/example.com/html
        StartFile = index.php
        AccessLogfile = /var/www/example.com/log/access.log
        ErrorLogfile = /var/www/example.com/log/error.log
        TimeForCGI = 180
        UseFastCGI = PHP5
        UseToolkit = drupal
    }

Example toolkits.conf:

    UrlToolkit {
        ToolkitID = drupal
        RequestURI isfile Return
        Match ^/favicon.ico$ Return
        Match /(.*)\?(.*) Rewrite /index.php?q=$1&$2
        Match /(.*) Rewrite /index.php?q=$1
    }

Example bindings.conf:

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
