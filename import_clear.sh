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

# check whether file exist
if [[ ! -f ${CURRENT_PATH}/${BACKUP_DIR}/${TODAY}.tar.gz ]]; then
    exit 0
fi

# unzip file to folder
tar -xzvf ${CURRENT_PATH}/${BACKUP_DIR}/${TODAY}.tar.gz -C ${CURRENT_PATH}/${BACKUP_DIR}
if [[ $? != 0 ]]; then
    exit $?
fi

# drop old database
docker exec -i ${MONGO_DOCKER_NAME} sh -c 'mongo vijos4 --eval "db.dropDatabase()"'
if [[ $? != 0 ]]; then
    exit $?
fi

# import data to mongo
docker exec -i ${MONGO_DOCKER_NAME} sh -c "mongorestore --drop --db vijos4 /backup/${TODAY}/vijos4"
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
