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