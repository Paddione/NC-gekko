docker network create -d bridge traefik-proxy 

docker compose -f /home/gekko/NC-gekko/traefik/traefik-compose.yml up -d
docker compose -f /home/gekko/NC-gekko/nextcloud/nextcloud-compose.yml up -d
cat /var/log/traefik.log
docker compose up -d

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

<img height="200" width="200"/>