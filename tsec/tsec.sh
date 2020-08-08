#!/usr/bin/env bash

SECRETS_DIR="teck-secrets"

function Init {
  mkdir -p $HOME/.bin
  [[ $(basename $(pwd)) != "tsec" ]] && { echo "Execute init only from directory with real tsec.sh"; exit 1; }
  ln -sf $(pwd)/tsec.sh $HOME/.bin/tsec
}

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


function SetTargetProject {
  echo "Please choose proper project to access to"

  local projects project
  gcloud config set project $(gcloud projects list | fzf --height 50% --header-lines=1 --reverse --multi --cycle | awk '{print $1}')
}

SetTargetProject

function EncryptFiles {
  echo -e "---------------\n- ENCRYPTING FILES"

  EncryptSafetyCheck
  FILES_LIST="$(find $1 -type f)"
  count=""

  for PLAIN_FILE in $FILES_LIST; do
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
    PLAIN_FILE=${ENCRYPTED_FILE%.enc} # % symbols removes extension after it
    # echo "PLAIN FILE IS [ $PLAIN_FILE ]"
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
  init)
    Init;;
  get)
    PullFiles;;
  save)
    PushFiles;;
  *)
    echo -e "Usage: \n init - make symlink. U better do before any other actions. \n get - get secrets to the current dir\n save - upload secrets to the bucket\n";;
esac
echo " "
