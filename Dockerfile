FROM centos:centos7
MAINTAINER Karl Stoney <karl.stoney@hp.com>

# Disable the annoying fastest mirror plugin
RUN sed -i '/enabled=1/ c\enabled=0' /etc/yum/pluginconf.d/fastestmirror.conf

# Install the EPEL repository and do a yum update
RUN yum -y -q install http://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm && \ 
    yum -y -q update && \
    yum -y -q install python-setuptools tar wget curl sudo which passwd && \
    yum -y -q clean all

# Install supervisor & supervisor stdout
RUN easy_install supervisor supervisor-stdout && \
    mkdir -p /etc/supervisord.d && \
    mkdir -p /var/log/supervisord && \
    mkdir -p /var/run && \
    mkdir -p /preboot

# Set the environment up
ENV TERM xterm-256color

# Setup users and Groups that we will use in sub containers.
# Users and Groups are a bit of a PITA with docker at the moment
RUN groupadd -g 1250 docker && \
    useradd -u 1250 -g 1250 docker && \
    chage -I -1 -m 0 -M 99999 -E -1 docker && \
    mkdir -p /storage && \
    chown docker:docker /storage

# Disable requiretty on sudo as we use it for context switching
# RUN echo "Defaults !requiretty" >> /etc/sudoers

# Add the supervisor configuration files and launch it
COPY supervisord.conf /etc/supervisord.conf
COPY preboot/* /preboot/

# Copy over our scripts and shell
COPY scripts/* /usr/local/bin/
RUN ln -s /usr/local/bin/hpess_shell.sh /etc/profile.d/hpess_shell.sh

WORKDIR /storage
ENV HPESS_ENV base
 
ENTRYPOINT ["/usr/local/bin/start_container.sh"]
