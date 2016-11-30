#!/usr/bin/env bash

# exit on error
set -e

export MYSQL_HOST=localhost
export MYSQL_USERNAME=root
export MYSQL_PASSWORD=root

# must be run inside the project. this is a hack for codeship
if [ ! -z ${1+x} ]; then
  cd $1
fi

#config setup
mkdir -p /var/alsocan
aws s3 sync s3://$AWS_S3_VPC/$AWS_S3_BUCKET/alsocan /var/alsocan/ --region=$AWS_DEFAULT_REGION --exact-timestamps
set > /var/alsocan/system/bash
cat $IH_DB_SQL | base64 -d > /var/alsocan/config/ih_db.sql
echo 'Config Setup Done.'

#mysql start and settings
service mysqld start
/usr/bin/mysqladmin -u root password root
mysql -h$MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE havells_ad_uat; CREATE DATABASE havells_ih_uat; CREATE DATABASE havells_vc_uat;"
mysql -h$MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD havells_ih_uat < /var/alsocan/config/ih_db.sql
echo 'MySQL Done.'


#install modules
composer install

echo 'Composer Install Done.'