#!/usr/bin/env bash
COPS_CWD=${COPS_CWD:-$(pwd)}
log() { echo "$@" >&2; }
vv() { log "($COPS_CWD) $@";"$@"; }
debug() { if [[ -n "${ADEBUG-}" ]];then log "$@";fi }
vvdebug() { if [[ -n "${ADEBUG-}" ]];then vv "$@";fi }
S=$(basename $0)
D=$(dirname $0)
local_folder="$COPS_CWD/local"
debug "local folder: $local_folder"
if [ ! -e "$local_folder" ];then
    log "local folder not found ($local_folder)"
    log "Maybe time to mkdir $local_folder or to cd into $COPS_CWD before launching commands"
    exit 1
fi
export cops_root="$local_folder/corpusops.bootstrap"
debug "cops_root folder: $cops_root"
if [ ! -e "$cops_root" ];then
    log "Maybe time to .ansible/scripts/download_corpusops.sh"
    exit 1
fi
real_script="$cops_root/hacking/deploy/$S"
real_env="$cops_root/hacking/deploy/ansible_deploy_env"
if [ ! -e "$real_script" ];then
    log "Corpusops script: $S not found (cops_root: $cops_root)"
    log "Maybe time to $cops_root/bin/install.sh -C -s"
    exit 1
fi
if ! vvdebug ln -sf "$real_env" "$D/ansible_deploy_env";then
    log "Symlinking env failed: $D/ansible_deploy_env"
    exit 1
fi
vvdebug "$real_script" "$@"
