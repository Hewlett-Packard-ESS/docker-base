# hpess/base
This is the base image which is use by all other images in this repository.  There are a few key components:

## Supervisor
The latest version of supervisor is installed, to enable us to run multiple processes in the container.  Any child containers of hpess/base can easily add new services to start at container boot by creating a service definition such as this:
```
[program:foo]
command=/bin/echo bar
```
And including it in your Dockerfile:
```
FROM hpess/base:latest
ADD yourservice.conf /etc/supervisord.d/yourservice.conf
```

## Persistence
/storage is exposed as a volume. 
