#!/bin/bash

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install -y docker-compose

# Create Docker directories
mkdir -p /opt/docker/{swag,nextcloud/{app,db}}

echo "Docker and Docker Compose installed. Directories created."