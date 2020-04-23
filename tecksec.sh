#!/usr/bin/env bash

SECRETS_DIR="teck-secrets"

function EncryptSafetyCheck {

cat <<EOF
###  ============== [ WARNING ] ============= ###
###    YOU ARE GOING TO ENCRYPT ALL FILES IN
### [ $(pwd) ]
###                  IS IT OK ?
###  ================ [ y/N ] =============== ###
EOF
  read answer
  [[ $answer != "y" ]] && echo "Exit." && exit 1

}

function EncryptFiles {
  echo -e "---------------\n- ENCRYPTING FILES"

  EncryptSafetyCheck
  FILES_LIST="$(find $1 -type f ! -name 'tecksec.sh')" 
  count=""

  for PLAIN_FILE in $FILES_LIST; do
    [ -f $PLAIN_FILE.enc ] && echo "File $(basename $PLAIN_FILE is already encrypted.)"
    echo " - $PLAIN_FILE > $PLAIN_FILE.enc"
    gcloud kms encrypt \
   --location global \
   --keyring storage \
   --key secrypt \
   --plaintext-file $PLAIN_FILE \
   --ciphertext-file $PLAIN_FILE.enc
    rm $PLAIN_FILE
   count=$((count + 1))
  done
  echo "- [ $count ] files encrypted."

}

function DecryptFiles { 
  echo -e "---------------\n- DECRYPTING FILES"

  FILES_LIST="$(find $1 -type f -name '*.enc')" 
  count=""

  for ENCRYPTED_FILE in $FILES_LIST; do
    PLAIN_FILE=${ENCRYPTED_FILE%.enc}
    echo " - $ENCRYPTED_FILE"
    gcloud kms decrypt \
   --location global \
   --keyring storage \
   --key secrypt \
   --ciphertext-file $ENCRYPTED_FILE \
   --plaintext-file $PLAIN_FILE
    rm $ENCRYPTED_FILE
   count=$((count + 1))
  done
  echo "- [ $count ] files decrypted."

}

function PullFiles {

cat <<EOF
# ======= [ GCP BUCKET > LOCALHOST ] ====== ###
# [ $(pwd)/$SECRETS_DIR ]
# =========== [ PRESS ENY KEY ] =========== ###
EOF
    read orly
    mkdir -p $SECRETS_DIR ${SECRETS_DIR}_enc
    gsutil -m rsync -d -r gs://$SECRETS_DIR ${SECRETS_DIR}_enc
    DecryptFiles ${SECRETS_DIR}_enc
  echo -e "---------------\n- COPYING ${SECRETS_DIR}_enc > $SECRETS_DIR"
    cp -r ${SECRETS_DIR}_enc/* $SECRETS_DIR 
  echo -e "---------------\n- REMOVING ${SECRETS_DIR}_enc"
    rm -rf ${SECRETS_DIR}_enc
}

function PushFiles {

cat <<EOF
# ======= [ LOCALHOST > GCP BUCKET ] ====== ###
# [ $(pwd)/$SECRETS_DIR ]
# =========== [ PRESS ENY KEY ] =========== ###
EOF
    read orly
    mkdir -p ${SECRETS_DIR}_enc
  echo -e "---------------\n- COPYING ${SECRETS_DIR} content > ${SECRETS_DIR}_enc"
    cp -r $SECRETS_DIR/* ${SECRETS_DIR}_enc
    EncryptFiles ${SECRETS_DIR}_enc
    gsutil -m rsync -d -r ${SECRETS_DIR}_enc gs://$SECRETS_DIR
  echo -e "---------------\n- REMOVING ${SECRETS_DIR}_enc"
    rm -rf ${SECRETS_DIR}_enc

}

case $1 in
  get)
    PullFiles;;
  save)
    PushFiles;;
  *)
    echo -e "Usage: \n get - get secrets to the current dir\n save - upload secrets to the bucket\n";;
esac
echo " "
