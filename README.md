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

## Chef-client
Chef-Client is pre installed and configured as a supervisor process, running on a 120 second interval.

The general idea is that chef-client will only provide surface level configuration of the container, no actual package installations.

In order for chef-client to run OK and register itself on the chef server, you need to provide it with a client.rb:
```
chef_server_url "https://your-chef-server"
ssl_verify_mode :verify_none
```
and a validation.pem, which you can get from the chef server itself.

So, your Dockerfile could look like this:
```
FROM hpess/base:latest
ADD client.rb /etc/chef/client.rb
ADD validation.pem /etc/chef/validation.pem
```
Or, your fig.yml could look like this:
```
chef:
  image: hpess/base
  volumes:
   - ./client:/etc/etc
```
where ./client contains a client.rb and validation.pem

## Persistence
/storage is exposed as a volume. 
