FROM centos:centos7
MAINTAINER Karl Stoney <karl.stoney@hp.com>

# Install the EPEL repository and do a yum update
RUN yum -y install http://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm && \ 
    yum -y update

# Install a bunch of packages we want, and then clean yum
RUN yum -y install python-setuptools tar wget curl which && \
    yum -y clean all

# Install supervisor
RUN easy_install supervisor supervisor-stdout

# Setup the directories that are required
RUN mkdir -p /etc/supervisord.d && \
    mkdir -p /var/log/supervisord && \
    mkdir -p /var/run

# Set the environment up
ENV TERM xterm-256color

# Expose mounts
VOLUME ["/storage"]
WORKDIR /storage

# Add the supervisor configuration files and launch it
ADD supervisord.conf /etc/supervisord.conf
CMD ["supervisord", "-c", "/etc/supervisord.conf", "-j", "/var/run/supervisor.pid"]
