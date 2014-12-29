#!/bin/bash

PREBOOT=`ls /preboot | wc -l`
if [ "$PREBOOT" -gt "0" ]; then
  echo "Executing preboot scripts..."
  for each in /preboot/*.sh ; do echo "Executing $each" ; bash $each ; done
fi

echo "Starting Supervisor..."
supervisord -c /etc/supervisord.conf &
SPID="$!"
echo "Supervisor PID: $SPID"

trap "kill $SPID >/dev/null 2>&1 && wait $SPID" exit INT TERM

wait $SPID
