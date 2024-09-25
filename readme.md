# Debian 12 LXC Container Setup with Docker, SWAG, and Nextcloud

## Table of Contents
1. [Initial Setup Script](#initial-setup-script)
2. [Docker Installation Script](#docker-installation-script)
3. [SWAG and Nextcloud Setup Script](#swag-and-nextcloud-setup-script)
4. [Config Files Bind Mount Script](#config-files-bind-mount-script)
5. [List of Important Config Files](#list-of-important-config-files)
6. [Environment Variables Setup](#environment-variables-setup)

## Initial Setup Script

Create a file named `initial_setup.sh`:

```bash
#!/bin/bash

# Update system
apt update && apt upgrade -y

# Install necessary packages
apt install -y curl gnupg lsb-release apt-transport-https ca-certificates

# Set up timezone
timedatectl set-timezone Europe/Berlin

# Configure resolv.conf
cat > /etc/resolv.conf << EOL
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 2606:4700:4700::1111
nameserver 2606:4700:4700::1001
search korczewski.de
options rotate
options timeout:2
EOL

echo "resolv.conf configured."

# Configure hosts file
cat > /etc/hosts << EOL
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

# Your LXC container's IP (replace with actual IP)
192.168.1.10    lxc-container.korczewski.de lxc-container

# Nextcloud
192.168.1.10    nextcloud.korczewski.de nextcloud

# Add other services as needed
192.168.1.10    service1.korczewski.de service1
192.168.1.10    service2.korczewski.de service2
EOL

echo "hosts file configured."

# Install SSH server
apt install -y openssh-server

# Configure SSH
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH service
systemctl restart ssh

echo "SSH installed and configured."

# Set up firewall
apt install -y ufw
ufw allow 2222/tcp
ufw --force enable

echo "Firewall configured."

echo "Initial setup complete."
```

## Docker Installation Script

Create a file named `install_docker.sh`:

```bash
#!/bin/bash

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install -y docker-compose

# Create Docker directories
mkdir -p /opt/docker/{swag,nextcloud/{app,db}}

echo "Docker and Docker Compose installed. Directories created."
```

## SWAG and Nextcloud Setup Script

Create a file named `setup_swag_nextcloud.sh`:

```bash
#!/bin/bash

# Create SWAG docker-compose file
cat > /opt/docker/swag/docker-compose.yml << EOL
version: "3"
services:
  swag:
    image: ghcr.io/linuxserver/swag
    container_name: swag
    cap_add:
      - NET_ADMIN
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
      - URL=korczewski.de
      - SUBDOMAINS=wildcard
      - VALIDATION=dns
      - DNSPLUGIN=cloudflare
    volumes:
      - /opt/docker/swag:/config
    ports:
      - 443:443
      - 80:80
    restart: unless-stopped
EOL

echo "SWAG docker-compose file created."

# Create Nextcloud docker-compose file
cat > /opt/docker/nextcloud/docker-compose.yml << EOL
version: '3'

services:
  nextcloud-db:
    image: mariadb:10.5
    container_name: nextcloud-db
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    restart: always
    volumes:
      - /opt/docker/nextcloud/db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=nextcloud_root_password
      - MYSQL_PASSWORD=nextcloud_password
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud

  nextcloud-app:
    image: nextcloud:latest
    container_name: nextcloud-app
    restart: always
    ports:
      - 8080:80
    links:
      - nextcloud-db
    volumes:
      - /opt/docker/nextcloud/app:/var/www/html
    environment:
      - MYSQL_PASSWORD=nextcloud_password
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_HOST=nextcloud-db

  nextcloud-cron:
    image: nextcloud:latest
    container_name: nextcloud-cron
    restart: always
    volumes:
      - /opt/docker/nextcloud/app:/var/www/html
    entrypoint: /cron.sh
    depends_on:
      - nextcloud-db
      - nextcloud-app

volumes:
  nextcloud-db:
  nextcloud-app:
EOL

echo "Nextcloud docker-compose file created."

# Start SWAG and Nextcloud
cd /opt/docker/swag && docker-compose up -d
cd /opt/docker/nextcloud && docker-compose up -d

echo "SWAG and Nextcloud containers started."
```

## Config Files Bind Mount Script

Create a file named `bind_config_files.sh`:

```bash
#!/bin/bash

# Create directory for config files
mkdir -p /opt/docker/config_files

# Bind mount critical config files
mount --bind /opt/docker/swag/nginx/proxy-confs /opt/docker/config_files/swag_proxy_confs
mount --bind /opt/docker/nextcloud/app/config /opt/docker/config_files/nextcloud_config

echo "Critical config files bind mounted to /opt/docker/config_files"
```

## List of Important Config Files

Here's a list of important config files you should work on:

1. `/etc/resolv.conf`
2. `/etc/hosts`
3. `/etc/ssh/sshd_config`
4. `/opt/docker/swag/nginx/proxy-confs/nextcloud.subdomain.conf`
5. `/opt/docker/nextcloud/app/config/config.php`
6. `/opt/docker/swag/docker-compose.yml`
7. `/opt/docker/nextcloud/docker-compose.yml`

## Environment Variables Setup

Create a file named `setup_env.sh`:

```bash
#!/bin/bash

# Function to generate a secure password
generate_password() {
    openssl rand -base64 16
}

# Prompt for passwords
read -sp "Enter MySQL root password: " mysql_root_pass
echo
read -sp "Enter MySQL Nextcloud user password: " mysql_nextcloud_pass
echo

# Generate other passwords
nextcloud_admin_pass=$(generate_password)
swag_puid=$(id -u)
swag_pgid=$(id -g)

# Create .env file
cat > /opt/docker/.env << EOL
MYSQL_ROOT_PASSWORD=$(echo -n "$mysql_root_pass" | openssl dgst -sha256 -hex | sed 's/^.* //')
MYSQL_NEXTCLOUD_PASSWORD=$(echo -n "$mysql_nextcloud_pass" | openssl dgst -sha256 -hex | sed 's/^.* //')
NEXTCLOUD_ADMIN_PASSWORD=$(echo -n "$nextcloud_admin_pass" | openssl dgst -sha256 -hex | sed 's/^.* //')
SWAG_PUID=$swag_puid
SWAG_PGID=$swag_pgid
EOL

echo "Environment variables set up in /opt/docker/.env"
echo "Make sure to update your docker-compose files to use these environment variables."
```

To use these scripts:

1. Copy each script into a file with the specified name.
2. Make the scripts executable: `chmod +x script_name.sh`
3. Run the scripts in order:
   ```
   ./initial_setup.sh
   ./install_docker.sh
   ./setup_env.sh
   ./setup_swag_nextcloud.sh
   ./bind_config_files.sh
   ```

Remember to review and modify the scripts as needed, especially replacing placeholder values like IP addresses and domain names with your actual values.

These scripts will set up your Debian 12 LXC container with Docker, SWAG, and Nextcloud, configure SSH, set up important config files, and create a .env file for storing sensitive information. The config files are bind mounted for easy access and management.

