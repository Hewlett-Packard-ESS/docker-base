FROM centos:centos7
MAINTAINER Karl Stoney <karl.stoney@hp.com>

# Install the EPEL repository and do a yum update
RUN yum -y install http://mirrors.nic.cz/epel/7/x86_64/e/epel-release-7-2.noarch.rpm && \ 
    yum -y update

# Install a bunch of packages we want, and then clean yum
RUN yum -y install python-setuptools tar wget curl which && \
    yum -y clean all

# Install supervisor
RUN easy_install supervisor

# Install chef-client
RUN curl -L https://www.opscode.com/chef/install.sh | bash

# Setup the directories that are required
RUN mkdir -p /etc/supervisord.d && \
    mkdir -p /etc/chef && \
    mkdir -p /var/log/supervisord

# Add the supervisor configuration files and launch it
ADD supervisord.conf /etc/supervisord.conf
ADD chef-client.service.conf /etc/supervisord.d/chef-client.service.conf
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
