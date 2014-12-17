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
## Supervisor-stdout
Supervisor-stdout is also installed, giving you the capability to redirect the stdout and stderr from your child process to PID 1, this meals you'll see the output when attaching to a container, or using fig logs.  To make use of this, add the following two lines to your program definitions:
```
[program:foo]
command=/bin/echo bar
stdout_events_enabled = true
stderr_events_enabled = true
```
## Persistence
/storage is exposed as a volume, stick stuff in there.
