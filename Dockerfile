FROM centos:centos7
MAINTAINER Karl Stoney <karl.stoney@hp.com>

# Disable the annoying fastest mirror plugin
RUN sed -i '/enabled=1/ c\enabled=0' /etc/yum/pluginconf.d/fastestmirror.conf

# Install the EPEL repository and do a yum update
RUN yum -y install http://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm && \ 
    yum -y update && \
    yum -y install python-setuptools tar wget curl sudo which passwd && \
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

# Any shell scripts in this directory will be executed before supervisor starts
VOLUME ["/preboot"]

# This is the working directory
WORKDIR /storage

# Add the supervisor configuration files and launch it
ADD supervisord.conf /etc/supervisord.conf

COPY start.sh /usr/local/bin/start.sh
CMD ["/usr/local/bin/start.sh"]
