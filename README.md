# Hiawatha on Debian Wheezy

This is a Docker container that provides the **[Hiawatha](http://www.hiawatha-webserver.org)** web server.

Usage is straightforward and relies only on a data volume mounted at */var/www*. There is a second volume for logging at */var/log/hiawatha*.

There is no PHP support built-in to the container. However, the startup script `run.sh` will make provision for linking to a PHP-FPM instance listening on port 9000. If this is not linked PHP scripts will return a `503` error.

Example usage:

    docker build -t heri16/hiawatha .
    docker run -P --name web --link fpm:fpm -v $HOME/www:/var/www -v $HOME/log:/var/log/hiawatha -v $HOME/hosts.conf:/etc/hiawatha/hosts.conf heri16/hiawatha

Some basic configuration changes have also been made to *haiwatha.conf* to enhance OOTB security.
