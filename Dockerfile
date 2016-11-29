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

RUN \
 curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" &&\
 unzip awscli-bundle.zip &&\
 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws &&\
 rm -rfv awscli-bundle awscli-bundle.zip

RUN \
 curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest &&\
 chmod 755 /usr/local/bin/ecs-cli
 

ADD scripts /scripts
RUN chmod -R 755 /scripts
ENV PATH $PATH:/scripts
