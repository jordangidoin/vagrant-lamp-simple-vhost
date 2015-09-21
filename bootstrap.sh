#!/usr/bin/env bash

echo " -- Updating System... -- "
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install debian-archive-keyring
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes upgrade
DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install debconf-utils

echo " -- Installing requirements... -- "
debconf-set-selections <<< 'mysql-server mysql-server/root_password password jefi'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password jefi'

debconf-set-selections <<< 'phpmyadmin phpmyadmin/password-confirm password jefi'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password jefi'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/setup-password password jefi'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password jefi'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password jefi'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'

DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install \
    zsh \
    apache2 \
    mysql-client mysql-server \
    php5-common php5-cli libapache2-mod-php5 php5-mysql \
    php-apc php5-json php5-mcrypt php5-curl php5-xdebug \
    php5-gd php5-xsl php5-xmlrpc php5-intl \
    phpmyadmin  \
    anacron  \
    git \
    vim \
    emacs \
    screen

echo " -- Configure... -- "
php5enmod mcrypt
ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
cat /var/vagrant_config_files/apache2/default | tee /etc/apache2/sites-available/default
sed -i '/display_errors = Off/c display_errors = On' /etc/php5/apache2/php.ini
sed -i '/error_reporting = E_ALL & ~E_DEPRECATED/c error_reporting = E_ALL | E_STRICT' /etc/php5/apache2/php.ini
sed -i '/html_errors = Off/c html_errors = On' /etc/php5/apache2/php.ini

echo " -- SET CACHE FOLDER... -- "
mkdir /var/www/cache && chmod -R 775 /var/www/cache  && chown vagrant:www-data /var/www/cache

echo " -- Restarting apache2... -- "
service apache2 restart