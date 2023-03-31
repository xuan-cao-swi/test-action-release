#!/usr/bin/env bash

echo "This is from extra_test"
ls -al
apt-get update && apt-get upgrade -y
apt-get install mysql-client -y 

mysql --host=$MYSQL_SERVER --user=$MYSQL_USER --password=$MYSQL_PASSWORD -e "show databases;"

cd home/
# ./full_install_rhel.sh