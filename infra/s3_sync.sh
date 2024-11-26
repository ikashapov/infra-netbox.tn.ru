#!/usr/bin/env bash

set -x #echo on

#Exit if a variable is not set
set -o nounset

#Exit on first error
set -o errexit

# role: storage.uploader not allow delete file
export AWS_ACCESS_KEY_ID=%ID%
export AWS_SECRET_ACCESS_KEY=%secret%
export AWS_DEFAULT_REGION=ru-central1

docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION amazon/aws-cli --endpoint-url=https://storage.yandexcloud.net s3 sync s3://tn-ru s3://tn-ru-stage --delete
