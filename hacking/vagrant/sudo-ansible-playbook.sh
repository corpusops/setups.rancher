#!/usr/bin/env bash
CONTENT=$(sudo cat /root/vagrant/provision_settings.sh)
eval "$(echo "$CONTENT")"
AP=ansible-playbook
if [ -e $COPS_ROOT ];then
    AP=$COPS_ROOT/bin/ansible-playbook
fi
sudo -HE "$AP" "${@}"
# vim:set et sts=4 ts=4 tw=80:
