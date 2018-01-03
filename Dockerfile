FROM alpine:3.7

# Upgrade base image software
RUN apk update
RUN apk upgrade

# Install utilities software
RUN apk add pwgen

# Install PHP
RUN apk add php7 php7-fpm php7-mysqli php7-zlib

# Configure PHP FPM
COPY config/php-fpm.conf /etc/php7/php-fpm.conf

# Install Nginx
RUN apk add nginx

# Add Nginx configuration files
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx.default.conf /etc/nginx/conf.d/default.conf

# Install Wordpress
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xzf latest.tar.gz -C /srv/

RUN rm latest.tar.gz
RUN rm /srv/wordpress/wp-config-sample.php

RUN chown -R nginx:www-data /srv/

# Expose HTTP/HTTPS ports
EXPOSE 80
EXPOSE 443

# Add Nginx log volume
VOLUME [ "/var/log/nginx" ]

# Run the entrypoint script
COPY entrypoint.sh /scripts/entrypoint.sh
RUN chmod +x /scripts/entrypoint.sh
ENTRYPOINT [ "/scripts/entrypoint.sh" ]

CMD ["nginx", "-g", "daemon off;"]
