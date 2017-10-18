#!/usr/bin/env bash


COPS_VAGRANT_DIR=${COPS_VAGRANT_DIR:-$(readlink -f "$(dirname $0)")}
. "$COPS_VAGRANT_DIR/common.sh" || exit 1
cd "$W"


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


cleanup () {
    if [[ -z $NO_CLEANUP ]];then
        # rm this cron on vbox
        rm /etc/cron.daily/mlocate
        if [[ -z $NO_APT_CLEANUP ]];then
            rm -vf /var/cache/apt/archives/*deb
            rm -rf  /var/lib/apt/lists/*
        fi
    fi
}


motd() {
    warn "Provision is finished"
    log "  Machine NUM: $CORPUSOPS_MACHINE_NUM"
    log "  Machine IP: $CORPUSOPS_PRIVATE_IP"
    log "  Machine Private network: $CORPUSOPS_PRIVATE_NETWORK"
    log "  Machine hostname: $CORPUSOPS_HOSTNAME"
    log "  Machine domain: $CORPUSOPS_DOMAIN"
}


extra() {
    #### extra image stuff
    echo
    /srv/rancher/rancherserver/cleanup.sh
}



parse_cli "$@"
cleanup
extra
motd
# vim:set et sts=4 ts=4 tw=80:
