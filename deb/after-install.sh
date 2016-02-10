#!/bin/sh
# postinst script for activemq

set -e

# summary of how this script can be called:
#        * <postinst> `configure' <most-recently-configured-version>
#        * <old-postinst> `abort-upgrade' <new version>
#        * <conflictor's-postinst> `abort-remove' `in-favour' <package>
#          <new-version>
#        * <postinst> `abort-remove'
#        * <deconfigured's-postinst> `abort-deconfigure' `in-favour'
#          <failed-install-package> <version> `removing'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

case "$1" in

  configure)
    # Create activemq user
    /usr/bin/getent group activemq >/dev/null || /usr/sbin/groupadd -r activemq
    /usr/bin/getent passwd activemq >/dev/null || /usr/sbin/useradd -r -g activemq -d /opt/activemq -s /usr/bin/nologin -c "ActiveMQ Service" -l -M activemq
    /bin/mkdir -p /var/log/activemq
    /bin/chown activemq:adm /var/log/activemq
    /bin/chmod 0750 /var/log/activemq
  ;;

  abort-upgrade|abort-remove|abort-deconfigure)
    exit 0
  ;;

  *)
    echo "postinst called with unknown argument \`$1'" >&2
    exit 1
  ;;

esac

exit 0
