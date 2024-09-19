networks:
beef:
enable_ipv6: true
driver: bridge
driver_opts:
com.docker.network.enable_ipv6: "true"
ipam:
driver: default
config:
- subnet: 2001:3984:3989::/64

docker network create -d macvlan \
--subnet=10.0.0.0/8 \
--gateway=1.0.0.1 \
-o parent=eth0.1 \
macvlan4

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


[//]: # (Make sure docker is installed:)
/home/patrick/NC-gekko/scripts/docker_install.sh

[//]: # (Create volume and run portainer)
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.1