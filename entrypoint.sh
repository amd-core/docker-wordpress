#!/usr/bin/env ash

if [ -d "/run/mysqld" ]; then
	echo "[i] mysqld already present, skipping creation"
	chown -R mysql:mysql /run/mysqld
else
	echo "[i] mysqld not found, creating...."
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi

if [ -d /var/lib/mysql/mysql ]; then
	echo "[i] MySQL directory already present, skipping creation"
	chown -R mysql:mysql /var/lib/mysql
else
	echo "[i] MySQL data directory not found, creating initial DBs"

	chown -R mysql:mysql /var/lib/mysql

	mysql_install_db --user=mysql > /dev/null

	if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
		MYSQL_ROOT_PASSWORD=`pwgen 16 1`
		echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
	fi

	DB_NAME=${DB_NAME:-""}
	DB_USER=${DB_USER:-""}
	DB_PASSWORD=${DB_PASSWORD:-""}

	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
	    return 1
	fi

	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
EOF

	if [ "$DB_NAME" != "" ]; then
	    echo "[i] Creating database: $DB_NAME"
	    echo "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

	    if [ "$DB_USER" != "" ]; then
		echo "[i] Creating user: $DB_USER with password $DB_PASSWORD"
		echo "GRANT ALL ON \`$DB_NAME\`.* to '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';" >> $tfile
	    fi
	fi

	/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
	rm -f $tfile
fi

echo "
<?php
define('DB_NAME', '$DB_NAME');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASSWORD');
define('DB_HOST', '127.0.0.1:3306');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

\$table_prefix  = 'wp_';

define('WP_DEBUG', false);
define('FS_METHOD', 'direct');

if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
" >> /srv/wordpress/wp-config.php

cat /srv/wordpress/wp-config.php

php-fpm7
# nginx

exec "$@"
