from centos:latest

# first set enforce=0
RUN setenforce 0 && \
    sed -i 's/enforcing/disabled/g' /etc/selinux/config

# Add repos
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    sed -i 's/^mirrorlist=https/mirrorlist=http/g' /etc/yum.repos.d/epel.repo && \
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# yum update
RUN yum update -y

# udpate repo
ADD misc/compass_install.repo 
# Install packages
RUN yum --enablerepo=compass_install --nogpgcheck install -y rsyslog logrotate ntp python python-devel git wget syslinux amqp mod_wsgi httpd bind rsync yum-utils gcc unzip openssl openssl098e ca-certificates mysql-devel mysql MySQL-python python-virtualenv python-setuptools python-pip bc libselinux-python libffi-devel openssl-devel


