#!/usr/bin/env bash


COPS_VAGRANT_DIR=${COPS_VAGRANT_DIR:-$(dirname "$(readlink -f "$0")")}
. "$COPS_VAGRANT_DIR/common.sh" || exit 1
cd "$W"


FORCE_CORPUSOPS_INSTALL=${FORCE_CORPUSOPS_INSTALL:-}
FORCE_CORPUSOPS_SYNC=${FORCE_CORPUSOPS_SYNC:-}


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


sync_ssh() {
    if [[ -n "${SKIP_ROOTSSHKEYS_SYNC}" ]];then
        log "Skip ssh keys sync to root user"
        return 0
    fi
    log "Synchronising user authorized_keys to root"
    if [ ! -e /root/.ssh ];then
        mkdir /root/.ssh
        chmod 700 /root/.ssh
    fi
    fics=""
    users="ubuntu vagrant"
    for u in ${users};do
        for i in $(ls /home/${u}/.ssh/authorized_key* 2>/dev/null);do
            fics="${fics} ${i}"
        done
    done
    if [ "x${fics}" != "x" ];then
        echo > /root/.ssh/authorized_keys
        for i in ${fics};do
            cat ${i} >> /root/.ssh/authorized_keys
            echo >> /root/.ssh/authorized_keys
        done
    fi
}


sync_corpusops() {
    if [[ -n "${SKIP_CORPUSOPS_SYNC}" ]];then
        log "Force skip sync corpusops"
        return 0
    fi
    if [[ -e "$COPS_ROOT/bin/install.sh" ]];then
        if [[ -n $FORCE_CORPUSOPS_SYNC ]]; then
            vv "$COPS_ROOT/bin/install.sh" -C -s
            die_in_error "sync"
        else
            log "Skip corpusops sync"
        fi
    else
        log "Skip corpusops sync, installer not found in $COPS_ROOT"
    fi
}


install_corpusops() {
    if [[ -n "${SKIP_CORPUSOPS_INSTALL}" ]];then
        log "Force skip install"
        return 0
    fi
    # in vagrant try to copy the code from the host inside the VM
    if [ -e "$HOST_COPS/.git" ];then
        rsync -azv --exclude=venv "$HOST_COPS/" "$COPS_ROOT/"
    fi
    if [ ! -e "$COPS_ROOT/.git" ] && [[ -n "$COPS_URL" ]] ;then
        git clone "$COPS_URL" "$COPS_ROOT"
    fi
    if [ ! -e "$COPS_ROOT/venv/bin/ansible" ] ||\
        ! ( has_command virtualenv ) ;then
        FORCE_CORPUSOPS_INSTALL=1
    fi
    if      [ ! -e "$COPS_ROOT/roles/corpusops.roles" ] \
        ||  [ ! -e "$COPS_ROOT/venv/src/ansible" ] \
        ||  [ ! -e "$COPS_ROOT/playbooks/corpusops" ] \
        ||  [ ! -e "$COPS_ROOT/venv/bin/ansible" ]; then
        FORCE_CORPUSOPS_SYNC=y
    fi
    if [[ -n $FORCE_CORPUSOPS_INSTALL ]]; then
        vv "$COPS_ROOT/bin/install.sh" -C -S
        die_in_error "install core"
    else
        log "Skip corpusops install"
    fi
}


install_sshfs() {
    if [[ -n "${SKIP_SSHFS_INSTALL}" ]];then
        log "Force skip install sshfs"
        return 0
    fi
    if ! has_command sshfs;then
        log "Install sshfs"
        if ! apt-get install sshfs;then
            apt-get update -qq && apt-get install sshfs
        fi
    else
        log "sshfs is installed"
    fi
}



parse_cli "$@"
sync_ssh          || die_in_error sync_ssh
install_corpusops || die_in_error install_corpusops
install_sshfs     || die_in_error install_sshfs
sync_corpusops    || die_in_error sync_corpusops
# vim:set et sts=4 ts=4 tw=80:
