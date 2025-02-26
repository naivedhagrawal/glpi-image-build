FROM php:8.2-apache

# Set environment variables
ENV GLPI_VERSION="10.0.12" \
    GLPI_PATH="/var/www/html"

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libxml2-dev \
    libldb-dev \
    libmcrypt-dev \
    libzip-dev \
    unzip \
    wget \
    mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli pdo pdo_mysql intl xml zip \
    && a2enmod rewrite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Download and extract GLPI
RUN wget -qO- "https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz" | tar -xz -C /var/www/html --strip-components=1 \
    && chown -R www-data:www-data ${GLPI_PATH} \
    && chmod -R 755 ${GLPI_PATH}

# Set ServerName to suppress warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]