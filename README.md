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
COPY yourservice.conf /etc/supervisord.d/yourservice.conf
```
## Supervisor-stdout
Supervisor-stdout is also installed, giving you the capability to redirect the stdout and stderr from your child process to PID 1, this meals you'll see the output when attaching to a container, or using fig logs.  To make use of this, add the following two lines to your program definitions:
```
[program:foo]
command=/bin/echo bar
stdout_events_enabled = true
stderr_events_enabled = true
```

## Pre-supervisor Setup
Sometimes you need to execute scripts before services are setup and configured.  In those situations please COPY an executable .sh file to the volume /preboot.

Any files in there will be executed PRIOR to supervisord starting.

## Profile.d
The entrypoint script to this container will execute $USER/.bashrc, /etc/bashrc, /etc/profile and /etc/profile.d/*.sh therefore if there are any environmental settings you whish to enforce, please create the relevant .sh files in /etc/profile.d

## Persistence
/storage is exposed as a volume, stick stuff in there.
