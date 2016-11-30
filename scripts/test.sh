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

# must be run inside the project. this is a hack for codeship
if [ ! -z ${1+x} ]; then
  cd $1
fi

#config setup
mkdir -p /var/alsocan
aws s3 sync s3://$AWS_S3_VPC/$AWS_S3_BUCKET/alsocan /var/alsocan/ --region=$AWS_DEFAULT_REGION --exact-timestamps
set > /var/alsocan/system/bash
export DB_CONFIG={"AD":{"driver":"mysql","host":"$MYSQL_HOST","port":"3306","database":"$DB_AD","username":"root","password":"root","charset":"utf8","collation":"utf8_unicode_ci","prefix":"","strict":false,"engine":null},"IH":{"driver":"mysql","host":"$MYSQL_HOST","port":"3306","database":"$DB_IH","username":"root","password":"root","charset":"utf8","collation":"utf8_unicode_ci","prefix":"","strict":false,"engine":null},"VC":{"driver":"mysql","host":"$MYSQL_HOST","port":"3306","database":"$DB_VC","username":"root","password":"root","charset":"utf8","collation":"utf8_unicode_ci","prefix":"","strict":false,"engine":null},"OA":{"driver":"mysql","host":"$MYSQL_HOST","port":"3306","database":"$DB_OA","username":"root","password":"root","charset":"utf8","collation":"utf8_unicode_ci","prefix":"","strict":false,"engine":null}}
echo $IH_DB_SQL > /var/alsocan/config/ih_db.sql
cat /var/alsocan/config/ih_db.sql | base64 -d > /var/alsocan/config/ih_db.sql



echo 'Config Setup Done.'

#mysql start and settings
service mysqld start
/usr/bin/mysqladmin -u root password root
mysql -h$MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD -e "CREATE DATABASE $DB_AD; CREATE DATABASE $DB_IH; CREATE DATABASE $DB_VC; CREATE DATABASE $DB_OA;"
mysql -h$MYSQL_HOST -u$MYSQL_USERNAME -p$MYSQL_PASSWORD $DB_IH < /var/alsocan/config/ih_db.sql
echo 'MySQL Done.'


#install modules
composer install

echo 'Composer Install Done.'

