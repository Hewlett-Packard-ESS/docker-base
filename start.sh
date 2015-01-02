#!/bin/bash
set -e
function debug() {
if [ "$DEBUG" == "true" ]; then
  DEBUG=${DEBUG:-"false"}
  echo " => $1"
fi
}
export -f debug

PREBOOT=`ls /preboot | wc -l`
if [ "$PREBOOT" -gt "0" ] && [ ! -f "/preboot.done" ]; then
  debug "Executing preboot scripts..."
  for each in /preboot/*.sh ; do debug "Executing: $each" ; bash $each "$@" ; done
  touch /preboot.done
fi

HOME=${HOME:-"/root"}
if [ "$#" -gt 0 ]; then
  set +e
  if [ -f "$HOME/.bashrc" ]; then
    debug "Executing $HOME/.bashrc"
    . $HOME/.bashrc
  fi
  if [ -f "/etc/profile" ]; then
    debug "Executing /etc/profile"
    . /etc/profile
  fi
  if [ -f "/etc/bashrc" ]; then
    debug "Executing /etc/bashrc"
    . /etc/bashrc
  fi
  set -e
  echo " => Executing: $*"
  $*
else
  SERVICES=`ls /etc/supervisord.d | wc -l`
  if [ "$SERVICES" -gt "0" ]; then
    echo " => Starting Supervisor..."
    supervisord -c /etc/supervisord.conf &
    SPID="$!"
    debug "Supervisor PID: $SPID"
    trap "echo ' => Please wait, gracefully shutting down...' && kill $SPID >/dev/null 2>&1 && wait $SPID" TERM INT
    wait $SPID
  else
    echo " => WARNING: There are no defined services in /etc/supervisord.d, skipping supervisor startup!"
  fi
fi
