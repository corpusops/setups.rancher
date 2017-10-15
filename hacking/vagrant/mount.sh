#!/usr/bin/env bash
cd "${VAGRANT_DIR:-$(dirname $0)/../..}"
. hacking/vagrant/common.sh || exit 1
if [ ! -e "${VM_MOUNTPOINT}" ];then
    mkdir "${VM_MOUNTPOINT}"
fi
hacking/vagrant/sshgen.sh\
    && vv sshfs -F "$(pwd)/.vagrant/cops-sshconfig" vagrant:/ "${VM_MOUNTPOINT}"
die_in_error "Error while mounting"
# vim:set et sts=4 ts=4 tw=80:
