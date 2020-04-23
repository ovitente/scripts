#!/bin/bash
 
PROJECT="Dotfiles"
CURRENT_USER=$USER
TARGET_USER="det"
PROJECT_DIR=~/x7/dist/configs

usage (){
  echo -e "Usage:\n
save - commit and push.
user - change username records to current username.
push - only git push.
get  - get last ver from repo."
}

changeUserToTarget() {
  echo "--------------------------------------------------"
  echo " - Replacing current user [ $USER ] to target user."

  if [[ $CURRENT_USER = $TARGET_USER ]]; then
    echo " - Current user [ $CURRENT_USER ] is already target user. Skipping"
  else
    cd ${PROJECT_DIR}
    grep -rli "\/${CURRENT_USER}\/" * | xargs -I@ sed -i "s/\/${CURRENT_USER}\//\/${TARGET_USER}\//g" @
    echo -e " - Done.\n"
    cd -
  fi
}

changeUserToCurrent() {
  echo "--------------------------------------------------"
  echo " - Replacing target user to [ $USER ]"

  if [[ $CURRENT_USER = $TARGET_USER ]]; then
    echo " - Current user [ $CURRENT_USER ] is already target user. Skipping"
  else
    cd ${PROJECT_DIR}
    grep -rli "\/${TARGET_USER}\/" * | xargs -I@ sed -i "s/\/${TARGET_USER}\//\/${CURRENT_USER}\//g" @
    echo -e " - Done.\n"
    cd -
  fi
}

pushToGit() {
  echo " - Saving dotfiles to the git repo."
  echo "--------------------------------------------------"
  cd ${PROJECT_DIR}
  git add . && git commit -a -m 'autosave' && git push
  cd -
}

pullFromGit() {
  echo " - Pulling last version of dotfiles."
  echo "--------------------------------------------------"
  cd ${PROJECT_DIR}
  git pull
  cd -
}

case $@ in

  save)
    changeUserToTarget
    pushToGit
    changeUserToCurrent
    ;;

  user)
    changeUserToCurrent
    ;;

  get)
    changeUserToTarget
    pullFromGit
    changeUserToCurrent
    ;;

  push)
    cd ${PROJECT_DIR}
    git push
    ;;

  fix)
    cd ${PROJECT_DIR}
    CURRENT_USER="ikostrub"
    grep -rli '\/${CURRENT_USER}\/' * | xargs -I@ sed -i 's/\/${CURRENT_USER}\//\/${TARGET_USER}\//g' @
    ;;
  *)

    usage;;
esac
