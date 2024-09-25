#!/bin/bash

# Create directory for config files
mkdir -p /opt/docker/config_files

# Bind mount critical config files
mount --bind /opt/docker/swag/nginx/proxy-confs /opt/docker/config_files/swag_proxy_confs
mount --bind /opt/docker/nextcloud/app/config /opt/docker/config_files/nextcloud_config

echo "Critical config files bind mounted to /opt/docker/config_files"