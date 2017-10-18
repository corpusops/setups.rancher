#!/usr/bin/env bash
cd "${VAGRANT_DIR:-$(dirname $0)/../..}"
. hacking/vagrant/common.sh || exit 1
usage () {
    NO_HEADER=y die '
Provision a vagrant vm

[NO_APT_CLEANUP=] \
    '"$0"'
'
}
parse_cli() {
    parse_cli_common "${@}"
}
parse_cli "$@"
# rm this cron on vbox
rm /etc/cron.daily/mlocate
if [[ -z $NO_APT_CLEANUP ]];then
    rm -vf /var/cache/apt/archives/*deb
    rm -rf  /var/lib/apt/lists/*
fi
# cleanup rancher & docker in one go
/srv/rancher/rancherserver/cleanup.sh
# vim:set et sts=4 ts=4 tw=80:
