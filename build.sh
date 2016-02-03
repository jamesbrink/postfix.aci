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
acbuild --debug run -- apk add postfix
acbuild --debug copy ./aci-assets/etc/postfix /postfix
acbuild --debug port add smtp tcp 25
acbuild --debug	set-exec -- /usr/sbin/postfix -c /etc/postfix
acbuild --debug write --overwrite postfix-latest-linux-amd64.aci

