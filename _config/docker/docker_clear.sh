#!/bin/bash

docker stop $(docker ps -a -q)
docker rm -v $(docker ps -a -q)
docker rmi $(docker images -a -q)
docker system prune -a
docker volume prune