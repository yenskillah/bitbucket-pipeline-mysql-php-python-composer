#!/usr/bin/env bash

# exit on error
set -e

export MYSQL_HOST=localhost
export MYSQL_USERNAME=root
export MYSQL_PASSWORD=root

service mysqld start
 /usr/bin/mysqladmin -u root password root
 mysql -h$MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE havells_ad_uat; CREATE DATABASE havells_ih_uat; CREATE DATABASE havells_vc_uat;"
mkdir -p /var/alsocan/config
mkdir -p /var/alsocan/system
