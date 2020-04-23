#!/bin/bash
# sshfsmounter.sh
# Usage: sshmount <server>

MOUNT_DIR="$HOME/.mount"
SERVER="$1"
CONNECTION_PATH="/"

usage() {
  echo -e " Usage: sshmount <server>"
}

checks(){
  if [ ! -d ${MOUNT_DIR} ];then
    mkdir -p ${MOUNT_DIR}
  fi

  if [ ! -d $HOME/.mount/${SERVER} ];then
    mkdir -p $HOME/.mount/${SERVER}
  fi

  if [ -z ${SERVER} ]; then
    echo " Server string was not provided."
    usage
    exit 1
  fi

}

ssh_connect() {
  checks
  sshfs ${SERVER}:${CONNECTION_PATH} ${HOME}/.mount/${SERVER}/
  cd ${MOUNT_DIR}/${SERVER}
}

ssh_connect
