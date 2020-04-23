#!/bin/bash
# mounter2.sh
# Usage: mounter.sh -t <type ssh/ftp/smb> <server>

MOUNT_DIR="$HOME/.mount"

usage() {
  echo -e " Usage: mounter.sh -t <type ssh/ftp/smb> <server>"
}

checks(){
  if [ ! -d ${MOUNT_DIR} ];then
    mkdir -p ${MOUNT_DIR}
  fi

  if [ -z ${SERVER} ]; then
    echo " Server string was not provided."
    usage
    exit 1
  fi

  if [ -z ${CONN_TYPE} ]; then
    CONN_TYPE="ssh"
    echo " Connection type cannot be empty. Using default [ ssh ]"
  fi

  if [ -z ${CONNECTION_PATH} ]; then
    CONNECTION_PATH="/"
    echo " Connection path was not provided, using default [ / ]"
  fi
}

conn_type_resolv() {
 case ${CONN_TYPE} in
   ssh) ssh_connect;;
   ftp) ftp_connect;;
   smb) smb_connect;;
   *) usage
      echo " Connection type [ ${CONN_TYPE} ] is not supported."
      exit 1;;
 esac
}

ssh_connect() {
  checks
  if [ ! -d $HOME/.mount/${SERVER} ];then
    mkdir -p $HOME/.mount/${SERVER}
  fi
  sshfs ${SERVER}:$CONNECTION_PATH $HOME/.mount/$SERVER/
#  sshfs "${SERVER}:${MOUNT_DIR}"
  cd ${MOUNT_DIR}
}

ftp_connect() {
  checks
  gvfs-mount "${SERVER}"
}

smb_connect() {
  checks
  gvfs-mount "${SERVER}"
}

while getopts t:s:p:i: option
do
  case "${option}" in
    i) CONNECTION_POINT=${OPTARG};;
    p) CONNECTION_PATH=${OPTARG};;
    s) SERVER=${OPTARG};;
    t) CONN_TYPE=${OPTARG};;
    *)
      usage
      exit 1;;
  esac
done

conn_type_resolv
