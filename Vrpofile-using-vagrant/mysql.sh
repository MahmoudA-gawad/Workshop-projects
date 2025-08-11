#!/bin/bash
DATABASE_PASS='admin123'
sudo su
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y
sudo yum install mariadb-server -y
##############
#Creating a directory for the vprofile-project

git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project/
#########################

# starting & enabling mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

echo "Successfully started and enabled mariadb-server."
#########################################
#connecting to the mariadb-server
#Secure_installation_script
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DATABASE_PASS';
CREATE DATABASE IF NOT EXISTS vprofile;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
#############################################
#Craeating a database named 'accounts'
mysql -u root -p$DATABASE_PASS <<EOF
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY '$DATABASE_PASS';
FLUSH PRIVILEGES;
exit
EOF
##########################################


#Copying the db_backup.sql file to the database
sudo mysql -u root -p$DATABASE_PASS accounts < src/main/resources/db_backup.sql
####################################################
# Restart mariadb-server
sudo systemctl restart mariadb


# #starting the firewall and allowing the mariadb to access from port no. 3306
# sudo systemctl start firewalld
# sudo systemctl enable firewalld
# sudo firewall-cmd --get-active-zones
# sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
# sudo firewall-cmd --reload
# sudo systemctl restart mariadb
