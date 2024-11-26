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

# Git secret
source ./secrets/.gitlab

# Project settings
source ./.build.deployment

# GitLab repository
source ./.build.repository

declare -A Tags

# copy env.${DEPLOYMENT} ./
mkdir -p "env.${DEPLOYMENT}"
cp -r ./env.${DEPLOYMENT}/. ./

#if [ -d "./env.${DEPLOYMENT}" ] 
#then
#    echo "Copy env.${DEPLOYMENT} to root"
#    cp -r ./env.${DEPLOYMENT}/. ./
#else
#    echo "env.${DEPLOYMENT} does not exists."
#fi

# Tags for Deployment
source ./.build.tags

urlEncode() {
    # urlEncode <string>

    #old_lc_collate=$LC_COLLATE
    #LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    #LC_COLLATE=$old_lc_collate
}

urlDecode() {
    # urlDecode <string>

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

# Date for archive folder name
d=$(date +%Y-%m-%d-%H-%M)
mkdir -p archive/${d}/

set +x #echo off

for service in "${!Tags[@]}"
do
  urlEncodePath=$(urlEncode "${URL[$service]}")
  tag="${Tags[$service]}"
  echo .
  echo "Service: $service"
  echo "Repo: ${URL[$service]}:$tag"
  echo "URL: https://gitlab.tn.ru/api/v4/projects/$urlEncodePath/repository/archive.tar.gz?sha=$tag"
  curl --header "Private-Token: ${GIT_TOKEN}" "https://gitlab.tn.ru/api/v4/projects/$urlEncodePath/repository/archive.tar.gz?sha=$tag" -o "$service.tar.gz";


  mv -f $service ./archive/${d}/ 2>/dev/null || true
  mkdir -p "$service"
  tar -xf "$service.tar.gz" -C "$service/" --strip-components 1
  mv "$service.tar.gz" ./archive/${d}/
  
  mkdir -p "patches/${service}"
  mkdir -p "patches.${DEPLOYMENT}/${service}"
done
set -x #echo on

cp -r ./patches/. ./
cp -r ./patches.${DEPLOYMENT}/. ./

cat ./secrets/.gitlab .build.deployment > .env

set +x #echo off
for service in "${!Tags[@]}"
do
  echo .
  echo -e "Service: $service tag: ${Tags[$service]}";
  export "TAG_${service}=${Tags[$service]}"
  echo "TAG_${service}=${Tags[$service]}" >> .env
done
set -x #echo on

docker compose -f docker-compose.common.yaml -f .docker-compose.yaml config > docker-compose.yaml

docker compose build --progress plain |& tee build-${d}.log

docker compose push

