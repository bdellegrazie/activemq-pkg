#!/bin/sh
/usr/bin/getent group activemq >/dev/null || groupadd --system activemq
/usr/bin/getent passwd activemq >/dev/null || useradd --system -g activemq -M --home /opt/activemq --shell /sbin/nologin --comment "ActiveMQ Service" activemq
exit 0
