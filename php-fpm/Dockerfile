FROM php:7.1-fpm-alpine
#FROM php:7.1-fpm
WORKDIR "/application"

ARG BUILD_DATE
ARG VCS_REF

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PHP_XDEBUG_DEFAULT_ENABLE ${PHP_XDEBUG_DEFAULT_ENABLE:-on}
ENV PHP_XDEBUG_REMOTE_ENABLE ${PHP_XDEBUG_REMOTE_ENABLE:-on}
ENV PHP_XDEBUG_REMOTE_HOST ${PHP_XDEBUG_REMOTE_HOST:-"127.0.0.1"}
ENV PHP_XDEBUG_REMOTE_PORT ${PHP_XDEBUG_REMOTE_PORT:-9000}
ENV PHP_XDEBUG_REMOTE_AUTO_START ${PHP_XDEBUG_REMOTE_AUTO_START:-on}
ENV PHP_XDEBUG_REMOTE_CONNECT_BACK ${PHP_XDEBUG_REMOTE_CONNECT_BACK:-on}
ENV PHP_XDEBUG_IDEKEY ${PHP_XDEBUG_IDEKEY:-PHPSTORM}
ENV PHP_XDEBUG_PROFILER_ENABLE ${PHP_XDEBUG_PROFILER_ENABLE:-0}
ENV PHP_XDEBUG_PROFILER_OUTPUT_DIR ${PHP_XDEBUG_PROFILER_OUTPUT_DIR:-"/tmp"}


#RUN apk update
RUN apk update \
    && apk add  --no-cache git mysql-client curl openssh-client icu libpng libjpeg-turbo libmcrypt libmcrypt-dev \
    && apk add --no-cache --virtual build-dependencies icu-dev \
    libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev g++ make autoconf \
    && docker-php-source extract \
    && pecl install xdebug redis \
    && docker-php-ext-enable xdebug redis \
    && docker-php-source delete \
    && docker-php-ext-install mcrypt pdo_mysql soap intl zip \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apk del build-dependencies \
    && apk del libmcrypt-dev \
    && rm -rf /tmp/* /tmp/* /var/lib/apt/lists/* /usr/share/doc/*

COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug-dev.ini
USER www-data
