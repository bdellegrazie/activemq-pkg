#!/bin/sh
# prerm script for activemq

set -e

# summary of how this script can be called:
#        * <prerm> `remove'
#        * <old-prerm> `upgrade' <new-version>
#        * <new-prerm> `failed-upgrade' <old-version>
#        * <conflictor's-prerm> `remove' `in-favour' <package> <new-version>
#        * <deconfigured's-prerm> `deconfigure' `in-favour'
#          <package-being-installed> <version> `removing'
#          <conflicting-package> <version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

case "$1" in
  remove|upgrade|deconfigure)
    # stop services
    if [ -x "/etc/init.d/activemq" ]; then
      if [ -x "`which invoke-rc.d 2>/dev/null`" ]; then
        invoke-rc.d activemq stop || true
      else
        /etc/init.d/activemq stop || true
      fi
    fi
  ;;

  failed-upgrade)
  ;;

  *)
    echo "prerm called with unknown argument \`$1'" >&2
    exit 1
  ;;
esac

exit 0
