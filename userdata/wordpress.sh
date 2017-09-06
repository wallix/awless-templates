#!/bin/bash

# Bash script to provision wodpress
# Original version by William Klassen - William.Klassen1@gmail.com - https://github.com/zn3zman/AWS-WordPress-Creation/blob/master/WP-Setup.sh
# Updated to only provision wordpress and use an external database

# Run the script with the below command as root ('sudo -i' or 'sudo su'). Most recent version will always be at that address.
# bash <(curl https://cdn.rawgit.com/zn3zman/AWS-WordPress-Creation/master/WP-Setup.sh)

# Set default variables from awless templating variables
wordpressdb="{{.Variables.dbname}}"
SQLHost="{{.Variables.dbhost}}"
SQLUser="{{.Variables.dbuser}}"
SQLPass="{{.Variables.dbpassword}}"

upgrademe=yes
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
nocolor=`tput sgr0`

# Update server (hopefully), install apache, mysql, php, etc depending on OS, then updates in case any of those were already installed
# This script handles basic amzn, ubuntu
# If your image has a custom /etc/os-release or /etc/issue, this probably won't work
OS=$(cat /etc/os-release | grep "ID" | grep -v "VERSION" | grep -v "LIKE" | sed 's/ID=//g' | sed 's/["]//g' | awk '{print $1}')
if [[ $OS = "amzn" ]]
then
	if [[ $upgrademe = "yes" ]]
	then
		yum upgrade -y
	fi
	yum install -y httpd mysql php php-mysql wget curl
	yum upgrade -y httpd mysql php php-mysql wget curl
	service mysqld start
elif [[ $OS = "ubuntu" ]]
then
	if [[ $upgrademe = "yes" ]]
	then
		yum apt-get update && apt-get upgrade -y
	fi
	export DEBIAN_FRONTEND=noninteractive
	apt-get install -y apache2 mysql php5 php5-mysql wget curl
	service mysql start
fi

# Move to the www directory
cd /var/www/html
#Error handling
if [ "$?" != "0" ]
then 
	echo "Apache's www directory not found. Exiting to prevent something bad."
	exit 1
fi

# Use wget to download the latest wordpress tar
if wget https://wordpress.org/latest.tar.gz
then 
	echo -e "\n"
else 
	# Older versions of wget won't download from sites using HTTPS with wildcard certs (*.wordpress.org). This checks for that.
	wget --no-check-certificate https://wordpress.org/latest.tar.gz
fi
#Error handling
if [ "$?" != "0" ]
then 
	echo "Couldn't download the wordpress tar. Is wordpress.org down? Exiting."
	exit 1
fi
tar -xzf latest.tar.gz
cd wordpress
mv -f * ../
cd ..
rm -f latest.tar.gz
rm -rf ./wordpress
rm -f index.html

# Create wp-config.php and give it some salt. Normal comments are removed because I'm lazy
WPSalts=$(curl https://api.wordpress.org/secret-key/1.1/salt/)
cat > ./wp-config.php <<-EOF
<?php
define('DB_NAME', '$wordpressdb');
define('DB_USER', '$SQLUser');
define('DB_PASSWORD', '$SQLPass');
define('DB_HOST', '$SQLHost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
$WPSalts
\$table_prefix  = 'wp_';
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
        define('ABSPATH', dirname(__FILE__) . '/');
require_once(ABSPATH . 'wp-settings.php');
EOF

# Create www group, add apache to that group, and set permissions on /var/www/html to let WordPress access and update itself. Not needed for Ubuntu?
echo -e "\n\nUpdating permissions. This may take a few minutes...\n\n"
if [[ $OS = "amzn" ]] || [[ $OS = "rhel" ]] || [[ $OS = "CentOS" ]]
then
	if ! groupadd www
	then 
		/usr/sbin/groupadd www
	fi
	usermod -a -G www apache
	chown -R apache /var/www
	chgrp -R www /var/www
	chmod 2775 /var/www
	find /var/www -type d -exec sudo chmod 2775 {} \;
	find /var/www -type f -exec sudo chmod 0664 {} \;
fi

# Lazy way to allow WordPress access to .htaccess files
# Also restart services, ensure services start on boot, and changes any other needed settings for php to run correctly
if [[ $OS = "amzn" ]]
then
	sed -i -e 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
	service httpd start
	chkconfig httpd on
elif [[ $OS = "ubuntu" ]]
then
	sed -i -e 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
	service apache2 start
fi
# Done
echo -e "\nNow go to${green} http://$(curl --silent http://bot.whatismyipaddress.com/) ${nocolor}in your browser to set up your site (it's vulnerable until you do)."
# You're welcome