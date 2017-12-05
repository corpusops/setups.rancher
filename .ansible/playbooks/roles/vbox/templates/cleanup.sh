#!/usr/bin/env bash
cd "$(dirname $0)"
id=$(docker-compose -f compose-server.yml ps|grep server|awk '{print $1}')
s=customcleanup.sql
cat > $s << EOF
use cattle;
delete from service_event;
delete from container_event;
delete from audit_log;
delete from service_log;
optimize table audit_log;
optimize table container_event;
optimize table external_handler_process;
optimize table generic_object;
optimize table global_load_balancer;
optimize table healthcheck_instance;
optimize table healthcheck_instance_host_map;
optimize table host;
optimize table host_ip_address_map;
optimize table host_label_map;
optimize table host_template;
optimize table host_vnet_map;
optimize table image;
optimize table image_storage_pool_map;
optimize table instance;
optimize table instance_host_map;
optimize table instance_label_map;
optimize table instance_link;
optimize table ip_address;
optimize table ip_address_nic_map;
optimize table ip_association;
optimize table ip_pool;
optimize table label;
optimize table load_balancer;
optimize table load_balancer_certificate_map;
optimize table load_balancer_config;
optimize table load_balancer_config_listener_map;
optimize table load_balancer_host_map;
optimize table load_balancer_listener;
optimize table load_balancer_target;
optimize table machine_driver;
optimize table mount;
optimize table network;
optimize table network_driver;
optimize table network_service;
optimize table network_service_provider;
optimize table network_service_provider_instance_map;
optimize table nic;
optimize table offering;
optimize table physical_host;
optimize table port;
optimize table process_execution;
optimize table process_instance;
optimize table project_member;
optimize table project_template;
optimize table resource_pool;
optimize table scheduled_upgrade;
optimize table secret;
optimize table service;
optimize table service_consume_map;
optimize table service_event;
optimize table service_expose_map;
optimize table service_index;
optimize table service_log;
optimize table setting;
optimize table snapshot;
optimize table snapshot_storage_pool_map;
optimize table storage_driver;
optimize table storage_pool;
optimize table storage_pool_host_map;
optimize table subnet;
optimize table subnet_vnet_map;
optimize table task;
optimize table task_instance;
optimize table ui_challenge;
optimize table user_preference;
optimize table vnet;
optimize table volume;
optimize table volume_storage_pool_map;
optimize table volume_template;
optimize table zone;
EOF
set -ex
docker cp $s  $id:/$s
#docker exec -ti $id bash -c "mysql < /$s"
docker exec $id bash -c "cat /$s|mysql"
DO_IMAGES_CLEANUP=y DO_CONTAINERS_CLEANUP=y DO_VOLUMES_CLEANUP=y \
    /srv/corpusops/corpusops.bootstrap/bin/cops_docker_cleanup.sh
# vim:set et sts=4 ts=4 tw=80:
