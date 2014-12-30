#!/bin/bash
PREBOOT=`ls /preboot | wc -l`
if [ "$PREBOOT" -gt "0" ] && [ ! -f "/preboot.done" ]; then
  echo " => Executing preboot scripts..."
  for each in /preboot/*.sh ; do echo " => Executing: $each" ; bash $each ; done
  touch /preboot.done
fi

HOME=${HOME:-"/root"}
if [ "$#" -gt 0 ]; then
  . $HOME/.bashrc
  echo " => Executing: $*"
  $*
else
  SERVICES=`ls /etc/supervisord.d | wc -l`
  if [ "$SERVICES" -gt "0" ]; then
    echo " => Starting Supervisor..."
    supervisord -c /etc/supervisord.conf &
    SPID="$!"
    echo " => Supervisor PID: $SPID"
    trap "echo ' => Please wait, gracefully shutting down...' && kill $SPID >/dev/null 2>&1 && wait $SPID" TERM INT
    wait $SPID
  else
    echo " => WARNING: There are no defined services in /etc/supervisord.d, skipping supervisor startup!"
  fi
fi
