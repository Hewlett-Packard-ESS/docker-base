FROM centos:centos7
MAINTAINER Karl Stoney <karl.stoney@hp.com>

# Disable the annoying fastest mirror plugin
RUN sed -i '/enabled=1/ c\enabled=0' /etc/yum/pluginconf.d/fastestmirror.conf

# Install the EPEL repository and do a yum update
RUN yum -y install http://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm && \ 
    yum -y update && \
    yum -y install python-setuptools tar wget curl sudo which passwd && \
    yum -y clean all

# Install supervisor & supervisor stdout
RUN easy_install supervisor supervisor-stdout && \
    mkdir -p /etc/supervisord.d && \
    mkdir -p /var/log/supervisord && \
    mkdir -p /var/run && \
    mkdir -p /preboot

# Set the environment up
ENV TERM xterm-256color

# Expose the working directory as a mount
VOLUME ["/storage"]
WORKDIR /storage

# Setup users and Groups that we will use in sub containers.
# Users and Groups are a bit of a PITA with docker at the moment
RUN groupadd -g 1250 hpess && \
    useradd -u 1250 -g 1250 hpess && \
    useradd -r -u 750 -g 1250 -s /sbin/nologin hpess_service && \
    chage -I -1 -m 0 -M 99999 -E -1 hpess && \
    chage -I -1 -m 0 -M 99999 -E -1 hpess_service 

# Add the supervisor configuration files and launch it
COPY supervisord.conf /etc/supervisord.conf
COPY start.sh /usr/local/bin/start.sh
COPY hpess_shell.sh /etc/profile.d/hpess_shell.sh
 
ENTRYPOINT ["/usr/local/bin/start.sh"]
