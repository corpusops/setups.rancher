#!/usr/bin/env bash
cd "${VAGRANT_DIR:-$(dirname $0)/../..}"
. hacking/vagrant/common.sh || exit 1
if [ -e "$VM_MOUNTPOINT/bin" ];then
    vv fusermount -u "${VM_MOUNTPOINT}"
    die_in_error "Error while umounting"
else
    log "$PWD not mounted"
fi
# vim:set et sts=4 ts=4 tw=80:
