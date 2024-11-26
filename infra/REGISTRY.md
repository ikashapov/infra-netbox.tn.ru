# Работа с Container Registry для хранения Docker образов

https://cloud.yandex.ru/docs/container-registry/

Создать Container Registry для хранения Docker образов
```
yc container registry create --name registry --folder-name {Project}
```

Получить список Container Registry в каталоге
```
yc container registry list --folder-name {Project}
```

Получить список репозиториев в каталоге
```
yc container repository list --folder-name {Project}
```

Управление политиками автоматического удаления Docker-образов
https://cloud.yandex.ru/docs/container-registry/operations/lifecycle-policy/lifecycle-policy-list

Посмотреть спиок политик удаления в реестре
```
yc container repository lifecycle-policy list --registry-name registry --folder-name {Project}
```

Создать политику удаления для репозитория
```
yc container repository lifecycle-policy create ^
   --folder-name {Project} ^
   --repository-name crpcc91s1b9vn6tunch9/{Project}/stage/mobile ^
   --active ^
   --name delete-untagged-48h ^
   --description "delete all untagged Docker images older than 48 hours" ^
   --rules ./infra/rules.json
```
.infra/rules.json

```json
[
  {
    "description": "delete all untagged Docker images older than 48 hours",
    "untagged": true,
    "expire_period": "48h"
  }
]
```
