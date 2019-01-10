#!/bin/bash

CONTAINER_NAME=tizen-studio-ide
TIZEN_USER=tizen
TIZEN_DIR=/home/${TIZEN_USER}/tizen-studio/

xhost +

[[ $(docker ps -f "name=${CONTAINER_NAME}" --format '{{.Names}}') == ${CONTAINER_NAME} ]] || (docker start ${CONTAINER_NAME} && sleep 5)

docker exec -u ${TIZEN_USER} -d ${CONTAINER_NAME} bash -c "cd /home/${TIZEN_USER} && ${TIZEN_DIR}$1"
