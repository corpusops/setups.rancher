#!/usr/bin/env bash
cd "${VAGRANT_DIR:-$(dirname $0)/../..}"
. hacking/vagrant/common.sh || exit 1
usage () {
    NO_HEADER=y die '
Provision a vagrant vm

[FORCE_CORPUSOPS_SYNC] \
[FORCE_CORPUSOPS_INSTALL] \
[SKIP_CORPUSOPS_SYNC] \
[SKIP_CORPUSOPS_INSTALL] \
[SKIP_ROOTSSHKEYS_SYNC] \
    '"$0"'
'
}
parse_cli() {
    parse_cli_common "${@}"
}
parse_cli "$@"
sync_ssh
install_corpusops
sync_corpusops
# vim:set et sts=4 ts=4 tw=80:
