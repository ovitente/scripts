#!/bin/bash
 
PROJECT="SCRIPTS"
PROJECT_DIR=~/x7/dist/scripts

usage (){
  echo -e "Usage:\n
save - commit and push.
push - only git push.
get  - get last ver from repo."
}

pushToGit() {
  echo " Saving to the git repo."
  cd ${PROJECT_DIR}
  git add . && git commit -a -m 'autosave' && git push
}

pullFromGit() {
  echo " Pulling last version of ${PROJECT}."
  cd ${PROJECT_DIR}
  git pull
}

case $@ in
  save)
    pushToGit
    ;;
  push)
    cd ${PROJECT_DIR}
    git push
    ;;
  get)
    pullFromGit
    ;;
  *)
    usage;;
esac

