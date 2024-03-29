# Use the official PHP 7.3 FPM image as a base image
FROM php:7.3-fpm

# add info created by me
LABEL Name=dev:php7.3-fpm \
    Version=0.0.1 \
    Maintainer="Weda Dewa <weda.dewa.yahoo.co.id>" \
    Description="Image PHP developer on Debian Linux."

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Install Docker CLI (Note that usually installing Docker inside a Docker container is not recommended)
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli


# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install system dependencies and other PHP extensions not related to specific database types
RUN apt-get update && apt-get install -y \
        libzip-dev \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        libpq-dev \
        libsqlite3-dev \
        curl \
        wget \
    && docker-php-ext-install zip mbstring xml pdo_sqlite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install xdebug and redis in the same layer as they don't have any extra dependencies
# Update PECL
RUN pecl channel-update pecl.php.net

# Install compatible version of xdebug for PHP 7.4
RUN pecl install xdebug-2.9.8 \
    && docker-php-ext-enable xdebug

# Install redis
RUN pecl install redis \
    && docker-php-ext-enable redis

# Install NVM (Node Version Manager)
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION node
RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# Make sure to source nvm when starting the shell.
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install MySQL client and related dependencies
RUN apt-get update \
    && apt-get install -y default-mysql-client \
    && docker-php-ext-install pdo_mysql mysqli\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PostgreSQL client and related dependencies
RUN apt-get update \
    && apt-get install -y postgresql-client \
    && docker-php-ext-install pdo_pgsql pgsql\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Update package information and install librdkafka-dev
RUN apt update && \
    apt install -y librdkafka-dev && \
    pecl install rdkafka && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enable the rdkafka extension by adding it to rdkafka.ini file
RUN echo "extension=rdkafka.so" | tee /usr/local/etc/php/conf.d/20-rdkafka.ini

# Set the working directory
WORKDIR /var/www/html

# Optional: If you want to write a custom php.ini, you could add:
# COPY ./php.ini $PHP_INI_DIR/conf.d/

# Copy over any scripts or additional setup you might have
# Example:
# COPY ./scripts/ /usr/local/bin/

# Start the PHP-FPM server
CMD ["php-fpm", "-F"]
