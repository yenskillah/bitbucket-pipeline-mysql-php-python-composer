#!/usr/bin/env bash

# exit on error
set -e

export MYSQL_HOST=localhost
export MYSQL_USERNAME=root
export MYSQL_PASSWORD=root
export DB_AD=ad
export DB_IH=ih
export DB_VC=vc
export DB_OA=oa

# must be running inside the project. this is a hack for codeship
if [ ! -z ${1+x} ]; then
  cd $1
fi

#############
#CONFIG SETUP
#############

#copy config from s3
aws s3 sync s3://$AWS_S3_VPC/$AWS_S3_BUCKET/alsocan /var/alsocan/ --region=$AWS_DEFAULT_REGION --exact-timestamps
#copy server.json and extract to /var/alsocan/parameters/bash
jq -r ' to_entries | map("export \(.key)=\(.value);")[] ' /var/alsocan/parameters/server.json >> /var/alsocan/parameters/bash

#set to local database
echo 'export DB_CONFIG=/var/alsocan/config/db_test.json;' >> /var/alsocan/parameters/bash

echo 'Config Setup Done.'

cat /var/alsocan/parameters/bash

######
#MYSQL
######
#mysql start and settings
service mysqld start
#set username and password
/usr/bin/mysqladmin -u $MYSQL_USERNAME password $MYSQL_PASSWORD
#create databases
mysql -h$MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE $DB_AD; CREATE DATABASE $DB_IH; CREATE DATABASE $DB_VC; CREATE DATABASE $DB_OA;"

echo $IH_DB_SQL > /var/alsocan/config/ih_db.sql
cat /var/alsocan/config/ih_db.sql | base64 -d > /var/alsocan/config/ih_db.sql
mysql -h$MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $DB_IH < /var/alsocan/config/ih_db.sql

echo 'MySQL Done.'

#load application profile
source /var/alsocan/parameters/bash

####################
#APPLICATION INSTALL
####################
composer install

echo 'Composer Install Done.'

####################
#DATABASE INSTALL
####################
php artisan migrate
php artisan db:seed

echo 'DB Install Done.'

#####################
#TEST THE APPLICATION
#####################
# vendor/bin/phpunit app/Modules/Core/tests
# vendor/bin/phpunit app/Modules/Card/tests
# vendor/bin/phpunit app/Modules/User/tests
# vendor/bin/phpunit app/Modules/Admin/tests

