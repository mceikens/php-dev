FROM php:7.4-fpm-alpine3.16

USER root

ENV TZ="Europe/Berlin"

RUN apk update
RUN apk add --no-cache \
    build-base \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    bzip2-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    curl \
    python3 \
    git \
    libxml2-dev \
    zlib-dev \
    libbz2 \
    openssl-dev \
    libxslt-dev \
    sqlite-dev \
    graphicsmagick \
    musl-locales \
    gmp-dev \
    make \
    gcc \
    autoconf \
    ghostscript \
    nfs-utils \
    libc-dev \
    pkgconfig \
    libgd \
    gd-dev \
    libressl-dev \
    oniguruma-dev \
    mariadb-client \
    imagemagick-dev \
    icu-dev \
    libcurl \
    curl-dev \
    gettext-dev \
    libzip-dev \
    shadow \
    mysql-client \
    bash

RUN apk upgrade --no-cache --ignore alpine-baselayout

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN pecl install imagick

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd shmop \
                          intl \
                          mbstring \
                          opcache \
                          pdo \
                          soap \
                          xml \
                          bz2 \
                          curl \
                          fileinfo\
                          ftp \
                          gettext \
                          simplexml \
                          tokenizer \
                          xsl \
                          pdo_mysql \
                          pdo_sqlite \
                          mysqli \
                          bcmath \
                          gmp \
                          zip \
                          sockets

RUN pecl install apcu-5.1.21
RUN pecl install redis
RUN docker-php-ext-enable apcu intl redis

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

RUN yes | pecl install xdebug-3.1.5

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

COPY ./conf.d/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
COPY ./conf.d/custom-xdebug.ini /usr/local/etc/php/conf.d/custom-xdebug.ini

COPY . /usr/share/nginx/html/app
RUN chown -R 1000.1000 /usr/share/nginx/html/


USER 1000
WORKDIR /usr/share/nginx/html/app

EXPOSE 9000
CMD ["php-fpm"]
