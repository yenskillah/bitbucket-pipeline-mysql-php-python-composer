FROM centos:6
MAINTAINER Sonny Ramos <sonnysidramos@gmail.com>

RUN \ 
yum -y install git openssh-client curl software-properties-common gettext zip mysql-server mysql-client apt-transport-https scl-utils

RUN \
yum -y update &&\
yum -y install epel-release &&\
yum -y install wget &&\
yum -y update &&\
yum -y install epel-release &&\
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm &&\
wget https://centos6.iuscommunity.org/ius-release.rpm &&\
rpm -Uvh ius-release*.rpm &&\
yum -y install php56u php56u-opcache php56u-xml php56u-mcrypt php56u-gd php56u-devel php56u-mysql php56u-intl php56u-mbstring php56u-bcmath &&\
curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/bin

ADD scripts /scripts
RUN chmod -R 755 /scripts
ENV PATH $PATH:/scripts
