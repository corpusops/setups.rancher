#!/usr/bin/env bash


COPS_VAGRANT_DIR=${COPS_VAGRANT_DIR:-$(dirname "$(readlink -f "$0")")}
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

play_ansible_playbooks() {
    if [[ -n $SKIP_CORPUSOPS_PLAY_PLAYBOOKS ]] && [[ -z $FORCE_CORPUSOPS_PLAY_PLAYBOOKS ]];then
        log "SKIP_CORPUSOPS_PLAY_PLAYBOOKS set, skip ansible dance"
        return 0
    fi
    . "$COPS_ROOT/venv/bin/activate"
    f=$(mktemp)
    cat > $f << EOF

from __future__ import (absolute_import, division, print_function)
import os, json, subprocess, sys, six, pprint, hashlib
sha = hashlib.sha256()
v = '/root/vagrant/playbooks.json'
try:
    with open(v) as fic:
        plays = json.loads(fic.read())
except IOError:
    plays = []
    sys.stderr.write('No playbooks found in {0}'.format(v))
force = os.environ.get('FORCE_CORPUSOPS_PLAY_PLAYBOOKS', "")
for playbookdefs in plays:
    for play, vars in six.iteritems(playbookdefs):
        env = os.environ.copy()
        varsf = vars.get('extra_vars', [])
        verbosity = vars.get('verbosity', '-vvv')
        color = vars.get('color', 'true')
        pythonunbuffered = vars.get('pythonunbuffered', '1')
        env["PYTHONUNBUFFERED"] = pythonunbuffered
        env["ANSIBLE_FORCE_COLOR"] = color
        inventory = vars.get('inventory', ['-i', '/tmp/corpusops-ansible/inventory/'])
        limit = vars.get('limit', ['-l', "$CORPUSOPS_MACHINE"])
        ea = vars.get('extra_args', [])
        cwd = vars.get('cwd', "$CORPUSOPS_HOST_MOUNTPOINT")
        marker_dir = vars.get('marker_dir', '/etc')
        ap = vars.get('playbook_command', "$COPS_ROOT/bin/ansible-playbook")
        if not isinstance(varsf, list): varsf = [varsf]
        variablesfiles = ["-e@{0}".format(v) for v in varsf]
        cmd = ([ap, verbosity] + inventory + limit + ea +
                variablesfiles + [play])
        sha.update(json.dumps(cmd))
        s = sha.hexdigest()
        marker = os.path.join(marker_dir, 'cops_ansible_done_{0}'.format(s))
        if force or not os.path.exists(marker):
            print("Playing {0} in {1}".format(cmd, cwd))
            subprocess.check_call(cmd, cwd=cwd, env=env)
            with open(marker, 'w') as fic:
                fic.write('')
        else:
            print("Already done {0} in {1}".format(cmd, cwd))
            print("Either rm -f {0} or "
                  "export FORCE_CORPUSOPS_PLAY_PLAYBOOKS".format(marker))
EOF
    ( python "$f"; )
    ret=$?
    rm -f "$f"
    die_in_error_ $ret "Ansible provisioning failed"
}


cleanup () {
    if [[ -n $NO_CLEANUP ]];then
        log "NO_CLEANUP set, skip cleanup"
        return 0
    fi
    # rm this cron on vbox
    rm -vf /etc/cron.daily/mlocate
    if [[ -z $NO_APT_CLEANUP ]];then
        rm -vf /var/cache/apt/archives/*deb
        rm -rf  /var/lib/apt/lists/*
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
    [[ -e /srv/rancher/rancherserver/cleanup.sh ]] && \
        /srv/rancher/rancherserver/cleanup.sh
}


parse_cli "$@"
play_ansible_playbooks
cleanup
extra
motd
# vim:set et sts=4 ts=4 tw=80:
