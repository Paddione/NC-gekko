docker compose -f /home/gekko/NC-gekko/traefik/docker-compose.yml up -d
docker compose -f /home/gekko/NC-gekko/nextcloud/docker-compose.yml up -d

|-- NC-gekko
|   |-- docker-compose.yml
|   |-- nextcloud
|   |   |-- data
|   |   `-- nextcloud-compose.yml
|   |-- readme.md
|   |-- scripts
|   |   `-- docker_install.sh
|   `-- traefik
|       |-- data
|       |   |-- config.yml
|       |   |-- letsencrypt
|       |   |   `-- acme.json
|       |   |-- traefik.log
|       |   `-- traefik.yml
|       `-- traefik-compose.yml
`-- traefik
    `-- data
|-- config.yml
|-- letsencrypt
|-- traefik.log
`-- traefik.yml

