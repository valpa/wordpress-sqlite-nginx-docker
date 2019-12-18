from nginx:latest
MAINTAINER Jerry <valpassing@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV DOCUMENT_ROOT /usr/share/nginx/html

#Install nginx php-fpm php-pdo unzip curl
RUN apt-get update 
RUN apt-get -y install php7.3-fpm unzip curl apt-utils php7.3-curl php7.3-gd php7.3-intl php-pear php7.3-imagick php7.3-imap php7.3-memcache php7.3-pspell php7.3-recode php7.3-sqlite php7.3-tidy php7.3-xmlrpc php7.3-xsl

RUN rm -rf ${DOCUMENT_ROOT}/*
RUN curl -o wordpress.tar.gz https://cn.wordpress.org/latest-zh_CN.tar.gz
RUN tar -xzvf /wordpress.tar.gz --strip-components=1 --directory ${DOCUMENT_ROOT}

RUN curl -o sqlite-plugin.zip https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip
RUN unzip sqlite-plugin.zip -d ${DOCUMENT_ROOT}/wp-content/plugins/
RUN rm sqlite-plugin.zip
RUN cp ${DOCUMENT_ROOT}/wp-content/plugins/sqlite-integration/db.php ${DOCUMENT_ROOT}/wp-content
RUN cp ${DOCUMENT_ROOT}/wp-config-sample.php ${DOCUMENT_ROOT}/wp-config.php
RUN mkdir -p /var/wordpress/database 
RUN sed -i "s/<?php/<?php\ndefine('DB_DIR', '\/var\/wordpress\/database\/');/" ${DOCUMENT_ROOT}/wp-config.php

# https detect patch based on HTTP_X_FORWARDED_PROTO for nginx
RUN sed -i "s/<?php/<?php\nif (\$_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https') { \$_SERVER['HTTPS'] ='on'; }/" ${DOCUMENT_ROOT}/wp-config.php 

RUN cp -rf ${DOCUMENT_ROOT}/wp-content/plugins/ ${DOCUMENT_ROOT}/wp-content/pkg-plugins/
RUN cp -rf ${DOCUMENT_ROOT}/wp-content/themes/ ${DOCUMENT_ROOT}/wp-content/pkg-themes/

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 10m/" /etc/nginx/nginx.conf
RUN sed -i -e "s|include /etc/nginx/conf.d/\*.conf|include /etc/nginx/sites-enabled/\*|g" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 10M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 10M/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf
RUN sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php5/fpm/pool.d/www.conf


RUN chown -R www-data.www-data ${DOCUMENT_ROOT}

COPY default /etc/nginx/sites-available/default
RUN mkdir -p /etc/nginx/sites-enabled
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

EXPOSE 80
EXPOSE 443

CMD cp --no-clobber -vr ${DOCUMENT_ROOT}/wp-content/pkg-plugins/* ${DOCUMENT_ROOT}/wp-content/plugins/ && cp --no-clobber -vr ${DOCUMENT_ROOT}/wp-content/pkg-themes/* ${DOCUMENT_ROOT}/wp-content/themes/ && service php5-fpm start && nginx
    
