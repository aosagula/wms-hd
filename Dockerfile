#FROM php:7.4-fpm
FROM php:8.1.23-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libssl-dev \  
    zip \
    unzip \
    cron
    

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Imap
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap

# Debug
RUN pecl install -o -f xdebug-3.2.2 \
    && docker-php-ext-enable xdebug

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


COPY ./docker-compose/php/php.ini /usr/local/etc/php/

COPY ./docker-compose/php/conf.d/99-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

COPY ./docker-compose/crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab

#RUN /usr/bin/crontab /etc/cron.d/crontab
RUN echo "* * * * * root php /var/www/artisan schedule:run >> /tmp/cron.log 2>&1" >> /etc/crontab

# Set working directory
WORKDIR /var/www

VOLUME /var/www

USER $user