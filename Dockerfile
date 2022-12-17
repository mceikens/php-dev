FROM php:8.0-fpm-alpine3.16

USER root

ENV TZ="Europe/Berlin"
RUN apk update
RUN apk add \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    build-base \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    vim \
    unzip \
    curl \
    python3 \
    py3-pip \
    git \
    gcc \
    libxml2-dev \
    zlib-dev \
    bzip2-dev \
    openssl-dev \
    libxslt-dev \
    sqlite-dev \
    graphicsmagick \
    gmp-dev \
    make \
    gcc \
    autoconf \
    ghostscript \
    nfs-utils \
    libc-dev \
    pkgconfig \
    gd-dev \
    libressl-dev \
    oniguruma-dev \
    mariadb-client \
    icu-dev \
    libcurl \
    curl-dev \
    gettext-dev \
    shadow \
    texlive \
    texlive-full \
    biber \
    linux-headers
RUN apk upgrade -f --no-cache --ignore alpine-baselayout

RUN wget -qO- "https://yihui.name/gh/tinytex/tools/install-unx.sh" | sh

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd mbstring shmop \
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

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

RUN yes | pecl install xdebug \
    && echo "zend_extension=xdebug" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=develop,debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini


RUN mkdir -p /usr/share/nginx/html/app

RUN chown -R www-data.www-data /usr/share/nginx/html/

USER www-data
WORKDIR /usr/share/nginx/html/app

EXPOSE 9000
CMD ["php-fpm"]
