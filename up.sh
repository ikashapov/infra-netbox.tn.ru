#!/usr/bin/env bash

# https://www.shellcheck.net/
# clean ENV from previous run
#for i in $(env | awk -F"=" '{print $1}') ; do
#unset $i ; done

# set -x or set -o xtrace expands variables and prints a little + sign before the line.
# set -v or set -o verbose does not expand the variables before printing.
# Use set +x and set +v to turn off the above settings.
set -x #echo on

#Exit if a variable is not set
set -o nounset

#Exit on first error
set -o errexit

# cd to folder with bash script
cd "$(dirname "${BASH_SOURCE[0]}")"

# Project settings
source ./.build.deployment

declare -A Tags

# copy env.${DEPLOYMENT} ./
mkdir -p "env.${DEPLOYMENT}"
cp -r ./env.${DEPLOYMENT}/. ./

# Tags for Deployment
source ./.build.tags

mkdir -p patches
mkdir -p patches.${DEPLOYMENT}
cp -r ./patches/. ./
cp -r ./patches.${DEPLOYMENT}/. ./

#cp docker-compose.${DEPLOYMENT}.yml docker-compose.yml

cat .build.deployment > .env

set +x #echo off
for service in "${!Tags[@]}"
do
  echo -e "Service: $service tag: ${Tags[$service]}";
  export "TAG_${service}=${Tags[$service]}"
  echo "TAG_${service}=${Tags[$service]}" >> .env

  mkdir -p "${service}"
done
set -x #echo on

docker login \
         --username iam \
         --password $(curl -H Metadata-Flavor:Google http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token | jq -r '.access_token') \
         cr.yandex

docker compose -f docker-compose.common.yaml -f .docker-compose.yaml config > docker-compose.yaml

docker compose pull

docker compose up -d

docker compose ps

# remove other DEPLOYMENT
rm -fr ./env.*/
rm -fr ./patches/
rm -fr ./patches.*/
rm -fr ./infra/

#docker compose logs -f
