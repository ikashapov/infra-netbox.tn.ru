secrets\.gitlab

# GitLab Auth
GITLAB_AUTH=kashapov:XXXXXX
GIT_TOKEN=XXXXXX
GIT_USER=kashapov

# Конвертируем файл secrets\.gitlab в base64 и вставляем в секрет GitHub GITLAB_KEY
# https://github.com/ikashapov/infra-%repo%/settings/secrets/actions
base64 .gitlab


# Создаем секрет на сервисной учетке
yc iam key create ^
    --cloud-id b1g94vb73dlv93sq1kso --folder-name tn-life ^
    --service-account-name registry -o secrets\key.json

# Конвертируем ключ в base64 и вставляем в секрет GitHub DOCKER_REGISTRY_KEY
# https://github.com/ikashapov/infra-%repo%/settings/secrets/actions
base64 secrets\key.json

# https://reachmnadeem.wordpress.com/2021/01/01/base64-encoding-and-decoding-using-openssl-in-windows/
openssl base64 -in secrets\key.json -out secrets\key.base64

# Используем секрет в docker
cat ./secrets/key.json | docker login \
--username json_key \
--password-stdin \
cr.yandex
