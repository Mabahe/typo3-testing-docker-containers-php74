#!/bin/bash
set -e
source /pd_build/buildconfig
set -x

minimal_apt_get_install \
  make \
  php-apcu \
  php-apcu-bc \
  php7.4 \
  php7.4-bcmath \
  php7.4-bz2 \
  php7.4-cli \
  php7.4-common \
  php7.4-curl \
  php7.4-dev \
  php7.4-gd \
  php7.4-gmp \
  php7.4-imap \
  php7.4-intl \
  php7.4-json \
  php7.4-mbstring \
  php7.4-mysql \
  php7.4-opcache \
  php7.4-pgsql \
  php7.4-pspell \
  php7.4-readline \
  php7.4-recode \
  php7.4-soap \
  php7.4-sqlite3 \
  php7.4-xml \
  php7.4-xmlrpc \
  php7.4-xsl \
  php7.4-zip \
  php-pear \
  php-redis \
  php-memcached \
  php-xdebug \
  re2c \

  #

# Enable apc on cli for unit tests
echo "apc.enable_cli=1" >> /etc/php/7.4/mods-available/apcu.ini
echo "apc.slam_defense=0" >> /etc/php/7.4/mods-available/apcu.ini

# Disable opcache on php 7.1 since that triggers segfaults 'zend_mm_heap corrupted' with vfsStream 1.6.4 (currently)
echo "opcache.enable_cli=0" >> /etc/php/7.4/cli/conf.d/10-opcache.ini

# Enable phar writing
sed -i s/';phar.readonly = On'/'phar.readonly = Off'/ /etc/php/7.4/cli/php.ini

# Restrict cli based php.ini settings for php -S web server to have sane values in acceptance tests
sed -i s/'memory_limit = -1'/'memory_limit = 2G'/ /etc/php/7.4/cli/php.ini
sed -i s/'max_execution_time = 30'/'max_execution_time = 240'/ /etc/php/7.4/cli/php.ini
sed -i s/'; max_input_vars = 1000'/'max_input_vars = 1500'/ /etc/php/7.4/cli/php.ini

echo "xdebug.max_nesting_level = 400" >> /etc/php/7.4/mods-available/xdebug.ini

# mssql driver
# pecl install sqlsrv
# echo extension=sqlsrv.so >> /etc/php/7.4/mods-available/sqlsrv.ini
# phpenmod sqlsrv

# Prepare an additional php.ini file that does *NOT* include xdebug
# can be used with:  php -n -c /etc/php/cli-no-xdebug/php.ini
mkdir /etc/php/cli-no-xdebug/
php -i | \
    grep "\.ini" | \
    grep -o -e '\(/[A-Za-z0-9._-]\+\)\+\.ini' | \
    grep -v xdebug | \
    xargs awk 'FNR==1{print ""}1' | \
    grep -v '^;' | \
    grep -v '^$' > /etc/php/cli-no-xdebug/php.ini

# Install common tools
minimal_apt_get_install \
  graphicsmagick \
  imagemagick \
  zip \
  unzip \
  sqlite3 \
  #

# Install latest composer
curl -sSL https://getcomposer.org/composer-2.phar -o /usr/bin/composer
chmod +x /usr/bin/composer
