# hpess/base
This is the base image which is use by all other images in this repository.  There are a few key components:

## Supervisor
The latest version of supervisor is installed, to enable us to run multiple processes in the container.  Any child containers of hpess/base can easily add new services to start at container boot by creating a service definition such as this:
```
[program:foo]
command=/bin/echo bar
user=docker
```
And including it in your Dockerfile:
```
FROM hpess/base:latest
COPY yourservice.conf /etc/supervisord.d/yourservice.conf
```

## None-Supervisor user
Supervisor is only used when there are multiple services defined in /etc/supervisord.d, if there is only a single file the container will just run directly the `command=` as the `user=` as defined in that file.  This is because theres no need for the additional overhead of supervisord, when you can set a container with a single process to `restart=always`.  However, if you want to force supervisord to do your process management then set the environment variable `FORCE_SUPERVISOR=true`.

## Supervisor-stdout
Supervisor-stdout is also installed, giving you the capability to redirect the stdout and stderr from your child process to PID 1, this meals you'll see the output when attaching to a container, or using fig logs.  To make use of this, add the following two lines to your program definitions:
```
[program:foo]
command=/bin/echo bar
user=docker
stdout_events_enabled = true
stderr_events_enabled = true
```

## Pre-supervisor Setup
Sometimes you need to execute scripts before services are setup and configured.  In those situations please COPY an executable .sh file to the volume /preboot.

Any files in there will be executed PRIOR to supervisord starting.

## Environment 
The entrypoint script to this container will execute $USER/.bashrc or /etc/bashrc, /etc/profile and /etc/profile.d/*.sh therefore if there are any environmental settings you whish to enforce, please create the relevant .sh files in /etc/profile.d
