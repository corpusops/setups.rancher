#!/usr/bin/env bash
set -x
cd "{{corpusops_rancher_agent_vars.root}}"
#
COLLOCATED=${COLLOCATED-{{corpusops_rancher_agent_vars.collocated}}}
host_ip="{{corpusops_rancher_agent_vars.host_ip}}"
base_url="{{corpusops_rancher_agent_vars.base_url}}"
token="{{corpusops_rancher_agent_vars.token}}"
#
url="$base_url/scripts/$token"
labels="{{corpusops_rancher_agent_vars.labels}}"
img="{{corpusops_rancher_agent_vars.image}}"
docker_sock="/var/run/docker.sock"
mountpoint="/var/lib/rancher"
if [[ -n ${COLLOCATED}  ]];then
    docker run \
        --rm --privileged \
        -v "$docker_sock":/var/run/docker.sock \
        -e "CATTLE_HOST_LABELS=$labels" \
        -e "CATTLE_AGENT_IP=$host_ip" \
        -e "CATTLE_URL_OVERRIDE=$base_url" \
        -v "$mountpoint":/var/lib/rancher \
        "$img" "$url"
else
    docker run \
        --rm --privileged \
        -v "$docker_sock":/var/run/docker.sock \
        -e "CATTLE_HOST_LABELS=$labels" \
        -e "CATTLE_AGENT_IP=$host_ip" \
        -v "$mountpoint":/var/lib/rancher \
        "$img" "$url"
fi
# vim:set et sts=4 ts=4 tw=80:
