#!/usr/bin/env bash
cd "${VAGRANT_DIR:-$(dirname $0)/../..}"
if [ ! -e .vagrant ];then mkdir .vagrant;fi
vagrant ssh-config | sed \
    -e "s/User .*/User root/g" \
    -e "s/Host .*/Host vagrant/g" > .vagrant/cops-sshconfig
if ! ( grep -q "Host vagrant" .vagrant/cops-sshconfig );then
    echo "pb with vagrant-sshconfig" >&2
    exit 1
fi
