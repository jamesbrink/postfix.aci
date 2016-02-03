#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script uses functionality which requires root privileges"
    exit 1
fi

acbuild --debug begin
# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

acbuild --debug set-name jamesbrink/postfix
acbuild --debug dep add quay.io/coreos/alpine-sh
acbuild --debug run -- apk update
acbuild --debug run -- apk add supervisor
acbuild --debug run -- apk add postfix
acbuild --debug run -- apk add rsyslog
acbuild --debug run -- apk add bash
acbuild --debug run -- rm -rf /etc/postfix
acbuild --debug copy ./aci-assets/etc/postfix/ /etc/postfix/
acbuild --debug copy ./aci-assets/etc/supervisor/conf.d/ /etc/supervisor/conf.d/
acbuild --debug copy ./aci-assets/usr/local/bin/ /usr/local/bin/
acbuild --debug port add smtp tcp 25
acbuild --debug run -- touch /var/log/maillog
acbuild --debug run -- chmod 640 /var/log/maillog
acbuild --debug	set-exec -- /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
acbuild --debug write --overwrite postfix-latest-linux-amd64.aci

