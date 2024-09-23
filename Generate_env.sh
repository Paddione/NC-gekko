#!/bin/bash

SECRETS_FILE=".secrets"

# Function to prompt for a value
prompt_for_value() {
    local prompt="$1"
    local value
    read -p "$prompt: " value
    echo "$value"
}

# Function to prompt for a password
prompt_for_password() {
    local prompt="$1"
    local password
    read -s -p "$prompt: " password
    echo
    echo "$password"
}

# Generate secrets file
{
echo "# Sensitive information and passwords"
echo "NEXTCLOUD_MYSQL_PASSWORD=$(prompt_for_password "Enter MySQL password for Nextcloud")"
echo "MYSQL_ROOT_PASSWORD=$(prompt_for_password "Enter MySQL root password")"
echo "CLOUDFLARE_EMAIL=$(prompt_for_value "Enter Cloudflare email")"
echo "CLOUDFLARE_API_KEY=$(prompt_for_password "Enter Cloudflare API key")"
echo "# Uncomment the line below if you're using an API token instead of global API key"
echo "# CLOUDFLARE_API_TOKEN=$(prompt_for_password "Enter Cloudflare API token")"
} > "$SECRETS_FILE"

echo ".secrets file generated successfully!"
echo "WARNING: The .secrets file contains sensitive information. Keep it secure and never share it publicly."