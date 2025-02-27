FROM php:8.2-apache

# Set environment variables
ENV GLPI_VERSION="10.0.12" \
    GLPI_PATH="/var/www/html/glpi"

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libxml2-dev libldb-dev \
    libzip-dev unzip wget \
    default-mysql-client netcat-traditional iputils-ping \
    libldap2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-ldap \
    && docker-php-ext-install gd mysqli pdo pdo_mysql intl xml zip ldap exif opcache \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Download and extract GLPI
RUN wget -qO /tmp/glpi.tgz "https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tgz" \
    && tar -xzf /tmp/glpi.tgz -C /tmp \
    && mv /tmp/glpi /var/www/html/ \
    && chown -R www-data:www-data ${GLPI_PATH} \
    && chmod -R 755 ${GLPI_PATH} \
    && rm -f /tmp/glpi.tgz

# Ensure missing directories and config_db.php exist
RUN mkdir -p ${GLPI_PATH}/config ${GLPI_PATH}/files \
    && touch ${GLPI_PATH}/config/config_db.php \
    && chown -R www-data:www-data ${GLPI_PATH}/config ${GLPI_PATH}/files ${GLPI_PATH}/config/config_db.php

# Set Apache configuration to allow external access
RUN echo "<Directory /var/www/html/glpi>\n    DirectoryIndex index.php\n    Require all granted\n</Directory>" > /etc/apache2/conf-available/glpi.conf \
    && a2enconf glpi

# Set ServerName to suppress warnings
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
