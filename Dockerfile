FROM debian:10

RUN apt-get update

RUN apt-get install -y sudo nano php7.3-fpm php7.3 php7.3-xml php7.3-gd php7.3-mysql php7.3-pdo php7.3-mbstring nginx supervisor

COPY default /etc/nginx/sites-available/default
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.3/fpm/php.ini && \
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]
COPY start.sh /start.sh
CMD ["./start.sh"]
EXPOSE 80