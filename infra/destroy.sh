#!/usr/bin/env bash

# set -x or set -o xtrace expands variables and prints a little + sign before the line.
# set -v or set -o verbose does not expand the variables before printing.
# Use set +x and set +v to turn off the above settings.
set -x #echo on

# cd to folder with bash script
cd "$(dirname "${BASH_SOURCE[0]}")"

# Stop containers
docker compose down -v

# Clean folder
rm -fr ./*
rm -fr ./.*

#  - all stopped containers
#  - all networks not used by at least one container
#  - all dangling images
#  - all dangling build cache
docker system prune -f

# remove all local volumes not used by at least one container.
docker volume prune -f

# Remove All images
docker rmi -f $(docker images -a -q)

# 
#docker volume rm -f $(docker volume ls -q)

# 
docker ps

#
docker images -a

#
docker volume ls

#
ls -la
