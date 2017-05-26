#!/bin/bash
##############################################################################
# Copyright (c) 2016-2017 HUAWEI TECHNOLOGIES CO.,LTD and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################
set -x
COMPASS_DIR=${BASH_SOURCE[0]%/*}

yum update -y

yum --nogpgcheck install -y which python python-devel git wget syslinux amqp mod_wsgi httpd bind rsync yum-utils gcc unzip openssl openssl098e ca-certificates mysql-devel mysql MySQL-python python-virtualenv python-setuptools python-pip bc libselinux-python libffi-devel openssl-devel vim net-tools

git clone git://git.openstack.org/openstack/compass-web $COMPASS_DIR/../compass-web/
rm -rf $COMPASS_DIR/../compass-web/.git

easy_install --upgrade pip
pip install --upgrade pip
pip install --upgrade setuptools
pip install --upgrade virtualenv
pip install --upgrade redis
pip install --upgrade virtualenvwrapper

source `which virtualenvwrapper.sh`
mkvirtualenv --system-site-packages compass-core
workon compass-core
cd /root/compass-deck
pip install -U -r requirements.txt
cd -

systemctl enable httpd
mkdir -p /var/log/httpd
chmod -R 777 /var/log/httpd
mkdir -p /var/www/compass_web/v2.5
cp -rf $COMPASS_DIR/../compass-web/v2.5/target/* /var/www/compass_web/v2.5/

echo "ServerName compass-deck:80" >> /etc/httpd/conf/httpd.conf
mkdir -p /opt/compass/bin
mkdir -p /opt/compass/db
cp -f $COMPASS_DIR/misc/apache/{ods-server.conf,http_pip.conf,images.conf,packages.conf} \
/etc/httpd/conf.d/
cp -rf $COMPASS_DIR/bin/* /opt/compass/bin/
mkdir -p /var/www/compass
ln -s -f /opt/compass/bin/compass_wsgi.py /var/www/compass/compass.wsgi
cp -rf /usr/lib64/libcrypto.so.6 /usr/lib64/libcrypto.so

mkdir -p /var/log/compass
chmod -R 777 /var/log/compass
chmod -R 777 /opt/compass/db
mkdir -p $COMPASS_DIR/compass
mv $COMPASS_DIR/{actions,api,apiclient,utils,db,tasks,deployment} $COMPASS_DIR/compass/
touch $COMPASS_DIR/compass/__init__.py
source `which virtualenvwrapper.sh`
workon compass-core
cd /root/compass-deck
python setup.py install
usermod -a -G root apache

yum clean all

cp $COMPASS_DIR/start.sh /usr/local/bin/start.sh
set +x
