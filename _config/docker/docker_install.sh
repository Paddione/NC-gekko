#!/bin/bash

sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce
sudo usermod -aG docker patrick
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
echo "Logout and then log back in to make the user account group active"
#!/bin/bash

# Create the user 'patrick' with UID and GID 1000
useradd -m -u 1000 -s /bin/bash patrick

# Set a password for patrick (you'll be prompted to enter it)
passwd patrick

# Create the docker group if it doesn't exist
groupadd -f docker

# Add patrick to the docker group
usermod -aG docker patrick

# Set patrick's GID to 1000
groupmod -g 1000 patrick

# Ensure patrick owns his home directory
chown -R patrick:patrick /home/patrick

# Create a .docker directory for patrick and set permissions
mkdir -p /home/patrick/.docker
chown -R patrick:patrick /home/patrick/.docker

# Allow patrick to use docker-compose without sudo
mkdir -p /usr/local/bin
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "User 'patrick' created with UID/GID 1000 and added to the docker group."
echo "Patrick can now use Docker and docker-compose without sudo."
echo "Please log out and log back in as patrick for the changes to take effect."