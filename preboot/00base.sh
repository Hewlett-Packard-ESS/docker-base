#!/bin/bash
chown docker:docker /storage
chown -R docker:docker /home/docker

if [ "$yum_verify" == "false" ]; then
  echo 'sslverify=false' >> /etc/yum.conf
fi
