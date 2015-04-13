#!/usr/bin/env bash

# debconf-set-selections <<< 'mysql-server mysql-server/root_password password rootpass'
# debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password rootpass'
apt-get update
# apt-get -y install mysql-server

apt-get install postgresql -y