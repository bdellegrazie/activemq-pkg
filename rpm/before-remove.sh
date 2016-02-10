#!/bin/sh

# stop service
if [ -x "/etc/init.d/activemq" ]; then
  /sbin/service activemq stop || true
fi

exit 0

