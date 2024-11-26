#/bin/bash

# docker run -it --mount type=bind,source=$(pwd),target=/repo --rm postgres bash /repo/pg_restore.stage.sh | tee pg_restore.stage.log

now=$(TZ=":Europe/Moscow" date +"%T")
echo "backup start: $now ------------------------------"

# PG backup
export PGPASSWORD=%pass%
export PGUSER=%user%
export PGDATABASE=%user%
export PGHOST=c-c9qh4qnh7rv2sjr35tei.rw.mdb.yandexcloud.net
export PGPORT=6432

mkdir -p /repo/debug
pg_dump -O -x -Fc > /repo/debug/backup.dump

now=$(TZ=":Europe/Moscow" date +"%T")
echo "restore start: $now ------------------------------"

### PG restore
export PGPASSWORD=%pass%
export PGUSER=%user%-stage
export PGDATABASE=%user%-stage
export PGHOST=c-c9qh4qnh7rv2sjr35tei.rw.mdb.yandexcloud.net
export PGPORT=6432

### do restore
pg_restore -d ${PGDATABASE} --clean --if-exists -n public --no-owner -1 /repo/debug/backup.dump

now=$(TZ=":Europe/Moscow" date +"%T")
echo "restore finish: $now ------------------------"
