FROM php:8.3-apache

# Installa le dipendenze necessarie per Magento 2
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    libicu-dev \
    libsodium-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    git \
    unzip \
    default-mysql-client \
    libssl-dev \
    imagemagick \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# Installa le estensioni PHP richieste da Magento 2
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    bcmath \
    intl \
    mysqli \
    pdo_mysql \
    soap \
    sockets \
    xsl \
    zip \
    opcache \
    calendar \
    exif \
    sodium

# Installa e abilita Imagick (solo se non esiste già)
RUN pecl install imagick

# Installa Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Configura Xdebug
RUN echo "xdebug.mode=develop,debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.log=/var/log/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=DOCKER" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Configura PHP per Magento 2
RUN echo "memory_limit=2G" >> /usr/local/etc/php/conf.d/magento.ini \
    && echo "max_execution_time=1800" >> /usr/local/etc/php/conf.d/magento.ini \
    && echo "upload_max_filesize=64M" >> /usr/local/etc/php/conf.d/magento.ini \
    && echo "post_max_size=64M" >> /usr/local/etc/php/conf.d/magento.ini

# Installa Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configura Apache
RUN a2enmod rewrite headers

# Imposta directory di lavoro
WORKDIR /var/www/html

# Riavvia Apache per applicare le modifiche
CMD ["apache2-foreground"]

