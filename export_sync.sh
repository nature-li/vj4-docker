#!/usr/bin/env bash

# set debug mode
# set -x

# set docker name
if [[ "empty${1}" == "empty" ]]; then
    MONGO_DOCKER_NAME=vj4-docker_mongodb_1
else
    MONGO_DOCKER_NAME=${1}
fi

# set docker mapping directory
BACKUP_DIR=backup

# string for today
TODAY=$(date +%Y%m%d)

# get script's location path
CURRENT_PATH=$(cd $(dirname $0) && pwd)

# drop directory if exists
rm -rf ${CURRENT_PATH}/${BACKUP_DIR}/${TODAY}

# make a directory in docker mapping directory
mkdir -p ${CURRENT_PATH}/${BACKUP_DIR}/${TODAY}

# export mongo data to directory made just now
docker exec -i ${MONGO_DOCKER_NAME} sh -c "mongodump --db vijos4 --out /backup/${TODAY}"
if [[ $? != 0 ]]; then
    exit $?
fi

# zip folder
tar -C ${CURRENT_PATH}/${BACKUP_DIR} -czvf ${CURRENT_PATH}/${BACKUP_DIR}/${TODAY}.tar.gz ${TODAY}
if [[ $? != 0 ]]; then
    exit $?
fi

# sync data to remote using rsync
/usr/bin/rsync -rtvzc --progress --password-file=/etc/client.pass ${CURRENT_PATH}/${BACKUP_DIR}/${TODAY}.tar.gz name@ip:tag
if [[ $? != 0 ]]; then
    exit $?
fi

# only keep last 7 day's data
DAYS=7
for ((i=${DAYS} + 30; i > ${DAYS}; i--)); do
    DT=$(eval "date +'%Y%m%d' -d'${i} days ago'")
    rm -rf ${CURRENT_PATH}/${BACKUP_DIR}/${DT}
    rm -rf ${CURRENT_PATH}/${BACKUP_DIR}/${DT}.tar.gz
done
