#!/usr/bin/env bash
sourcefile() {
    for i in $@;do
        . "$i"
        if [[ $? != 0 ]];then
            echo "$i sourcing failed"
            exit 1
        fi
    done
}

VAGRANT=
if [ -e /host/.vagrant ] || [ -e /root/vagrant/provision_settings.sh ];then
    sourcefile /root/vagrant/provision_settings.sh
    VAGRANT=1
fi

W=${W:-$(pwd)}
DEFAULT_COPS_ROOT="/srv/corpusops/corpusops.bootstrap"
DEFAULT_COPS_URL="https://github.com/corpusops/corpusops.bootstrap.git"
LOGGER_NAME=${LOGGER_NAME:-vagrantvm}
COPS_URL=${COPS_URL-$DEFAULT_COPS_URL}
COPS_ROOT=${COPS_ROOT:-$(pwd)/local/corpusops.bootstrap}
HOST_MOUNTPOINT=${CORPUSOPS_HOST_MOUNTPOINT:-/host}
HOST_COPS=${CORPUSOPS_HOST_COPS:-$HOST_COPS/local/corpusops.bootstrap}
VM_MOUNTPOINT=$(pwd)/local/mountpoint
FORCE_CORPUSOPS_INSTALL=${FORCE_CORPUSOPS_INSTALL:-}
FORCE_CORPUSOPS_SYNC=${FORCE_CORPUSOPS_SYNC:-}


if [ ! -e "$COPS_ROOT/.git" ];then
    # in vagrant try to copy the code from the host inside the VM
    if [ -e "$HOST_COPS/.git" ];then
        rsync -azv --exclude=venv "$HOST_COPS/" "$COPS_ROOT/"
    fi
    # In any cases, clone cops if not found
    if [ ! -e "$COPS_ROOT/.git" ] && [[ -n "$COPS_URL" ]];then
        git clone "$COPS_URL" "$COPS_ROOT"
    fi
fi

sourcefile $COPS_ROOT/bin/cops_shell_common

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
        log "Force skip install"
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
        log "Skip corpusops installer, not found in $COPS_ROOT"
    fi
}

install_corpusops() {
    if [[ -n "${SKIP_CORPUSOPS_INSTALL}" ]];then
        log "Force skip install"
        return 0
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
# vim:set et sts=4 ts=4 tw=80:
