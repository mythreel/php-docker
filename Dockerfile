FROM debian:10

RUN apt-get update
RUN apt-get install -y lsb-release apt-transport-https ca-certificates wget sudo 
RUN sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

RUN apt-get update
RUN apt-get install -y nano php7.4-fpm php7.4 php7.4-xml php7.4-gd php7.4-mysql php7.4-pdo php7.4-mbstring nginx supervisor msmtp msmtp-mta mailutils

COPY msmtprc /etc/msmtprc
RUN chown www-data:www-data /etc/msmtprc
COPY default /etc/nginx/sites-available/default
RUN sed -i -e 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.4/fpm/php.ini && \
    echo "\ndaemon off;" >> /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN echo "sendmail_path = /usr/bin/msmtp -t -i" >> /etc/php/7.4/cli/php.ini
RUN echo "sendmail_path = /usr/bin/msmtp -t -i" >> /etc/php/7.4/fpm/php.ini

RUN chmod 600 /etc/msmtprc
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /run/php
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www/html"]
COPY start.sh /start.sh
CMD ["./start.sh"]
EXPOSE 80