#!/bin/bash

##############################################################
## Install LAMP script v.0.9 for CENTOS-7 AWS Lightsail     ##
##                                                          ##
## !Important!                                              ##
## Before running it change to ROOT user: 'sudo su -        ##
## And add Exec permissions                                 ##
##############################################################

### Install Repos & utils ###
yum install epel-release -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum install yum-utils -y
yum install wget -y
yum-config-manager --enable remi-php73
yum install https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm -y

### Update OS ###
yum update -y #Remove if not needed

### Install Apache & MySQL ###
yum install httpd -y
yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-zip php-fileinfo php-pear -y
yum install mysql-community-server -y

### Configure SWAP ###

#Create a SWAP file
dd if=/dev/zero of=/var/swapfile bs=1024 count=1048576
chmod 600 /var/swapfile
mkswap /var/swapfile
swapon /var/swapfile
cp /etc/fstab /etc/fstab.bak
echo '/var/swapfile none swap sw 0 0' | tee -a /etc/fstab
swapon -a


### Start optimization from here ###

#Swap optimizations
cp /etc/sysctl.conf /etc/sysctl.conf.bak
sysctl vm.swappiness=15
sysctl vm.vfs_cache_pressure=50
echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf
sysctl -p

#Chmod Apache directories
usermod -a -G centos centos
chown -R centos:centos /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

#Backup HTTPD
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak

#Basic security hardening for Apache
cat >>/etc/httpd/conf/httpd.conf <<EOL
#Removing from security reasons
ServerSignature Off
ServerTokens Prod
TraceEnable Off
KeepAlive off
EOL

#Disable directory browsing
sed -i -e 's/Options Indexes FollowSymLinks/Options FollowSymLinks/g' /etc/httpd/conf/httpd.conf

#Disable X-powered by PHP
sed -i -e 's/expose_php = On/expose_php = Off/g' /etc/php.ini

sleep 2

### Enable & Start LAMP ###
systemctl enable httpd.service
systemctl enable mysqld.service
systemctl restart httpd.service
systemctl restart mysqld.service
