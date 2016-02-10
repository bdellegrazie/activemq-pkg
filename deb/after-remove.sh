#!/bin/sh
# postrm script for activemq

set -e

# summary of how this script can be called:
#        * <postrm> `remove'
#        * <postrm> `purge'
#        * <old-postrm> `upgrade' <new-version>
#        * <new-postrm> `failed-upgrade' <old-version>
#        * <new-postrm> `abort-install'
#        * <new-postrm> `abort-install' <old-version>
#        * <new-postrm> `abort-upgrade' <old-version>
#        * <disappearer's-postrm> `disappear' <r>overwrit>r> <new-version>
# for details, see http://www.debian.org/doc/debian-policy/ or
# the debian-policy package

case "$1" in
  purge)
    if [ -d /var/log/activemq ]; then
      rm -rf /var/log/activemq
    fi
  ;;

  remove|upgrade|failed-upgrade|abort-install|abort-upgrade|disappear)
  ;;

  *)
    echo "postrm called with unknown argument \`$1'" >&2
    exit 1
  ;;
esac

exit 0

