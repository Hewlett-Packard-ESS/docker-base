#!/bin/bash
set -e
function debug() {
if [ "$DEBUG" == "true" ]; then
  DEBUG=${DEBUG:-"false"}
  echo "[DEBUG] $1"
fi
}
export -f debug

function warn() {
  echo "[WARN] $1"
}
export -f warn

function info() {
  echo "[INFO] $1"
}
export -f info


PREBOOT=`ls /preboot | wc -l`
if [ "$PREBOOT" -gt "0" ] && [ ! -f "/preboot.done" ]; then
  info "Executing preboot scripts..."
  for each in /preboot/*.sh ; do debug "Executing: $each" ; bash $each "$@" ; done
  touch /preboot.done
fi

HOME=${HOME:-"/root"}
if [ "$#" -gt 0 ]; then
  set +e
  if [ -f "$HOME/.bashrc" ]; then
    debug "Executing $HOME/.bashrc"
    . $HOME/.bashrc
  else
    debug "Executing /etc/bashrc"
    . /etc/bashrc
  fi
  if [ -f "/etc/profile" ]; then
    debug "Executing /etc/profile"
    . /etc/profile
  fi
  set -e
  echo " => Executing: $*"
  $*
else

  function finish {
     debug "Detected SIGTERM, Gracefully Shutting Down..."
     debug "Forwarding SIGTERM to Child PID: $child"
     `sleep 2; kill -TERM $child` &
     wait $parent
  }
  trap finish TERM INT

  SERVICES=`ls /etc/supervisord.d | wc -l`
  if [ "$SERVICES" -eq "1" ] || [ "$FORCE_SUPERVISOR" == "true" ]; then
    SERVICE_FILE=`ls -1 /etc/supervisord.d`
    SERVICE_NAME=`cat /etc/supervisord.d/$SERVICE_FILE | grep -i '\[program:' | awk -F'program:' '{print "["$2}'`
    SERVICE_USER=`cat /etc/supervisord.d/$SERVICE_FILE | grep -i 'user=' | awk -F'user=' '{print $2}'`
    SERVICE_USER=${SERVICE_USER:-root}
    SERVICE_COMMAND=`cat /etc/supervisord.d/$SERVICE_FILE | grep -i 'command=' | awk -F'command=' '{print $2}'`
    SERVICE_ENV=`cat /etc/supervisord.d/$SERVICE_FILE | grep -i 'environment' | awk -F'environment=' '{print $2}'`
    if [ ! "$SERVICE_ENV" == "" ]; then
      SERVICE_ENV=${SERVICE_ENV//\"/}
      declare ${SERVICE_ENV//,/ }
      export ${SERVICE_ENV//,/ }
    fi
    info "Only a single process defined in supervisord.  Starting $SERVICE_NAME directly!"
    debug "Executing '$SERVICE_COMMAND' as $SERVICE_USER"
    su $SERVICE_USER -c "$SERVICE_COMMAND" &
    parent=$!
  elif [ "$SERVICES" -gt "1" ]; then
    info "Multiple processes defined in supervisor config, starting supervisord..."
    su root -c "supervisord -c /etc/supervisord.conf" &
    parent=$!
  else
    warn "There are no defined services in /etc/supervisord.d, skipping supervisor startup!"
    exit 0
  fi
  sleep 1
  child=$(pgrep -P $parent )
  debug "Parent PID: $parent, Child PID: $child"
  wait $parent
fi
