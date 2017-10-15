#!/usr/bin/env bash
cd "${VAGRANT_DIR:-$(dirname $0)/../..}"
. hacking/vagrant/common.sh || exit 1
usage () {
    NO_HEADER=y die '
Export a vagrant vm

    '"$0"' export_name
'
}
BOX=${BOX:-${1}}
parse_cli() {
    parse_cli_common "${@}"
    if [ -z "${BOX}" ];then
        die "give a box name"
    fi
}
parse_cli "$@"
if vagrant status | egrep -q running;then
    die "Vagrant is running, poweroff VMs first with: vagrant halt -f"
fi
vv vagrant package --output "${BOX}.box" \
    $([[ -f vagrant_config.yml ]] && \
            echo --include vagrant_config.yml ; )
die_in_error "vagrant export to $BOX failed"
# vim:set et sts=4 ts=4 tw=80:
