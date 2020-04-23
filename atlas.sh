#!/bin/bash
 
PROJECT="ATLAS"
ATLAS_DIR=~/x7/projects/x7/atlas

usage (){
  echo -e "Usage:\n
save - commit and push.
get  - get last ver from repo."
}

pushToGit() {
  echo " Saving to the git repo."
  cd ${ATLAS_DIR}
  git add . && git commit -a -m 'autosave' && git push
}

pullFromGit() {
  echo " Pulling last version of ${ATLAS}."
  cd ${ATLAS_DIR}
  git pull
}

case $@ in
  save)
    pushToGit
    ;;
  push)
    cd ${ATLAS_DIR}
    git push
    ;;
  get)
    pullFromGit
    ;;
  *)
    usage;;
esac

