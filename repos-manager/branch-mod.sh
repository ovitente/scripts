#!/usr/bin/env bash

REPOSITORIES_LIST="
finance-tg-bot
logo-changer
scripts
ssh-gen
teamspeak-tutorial"


for REPO in $REPOSITORIES_LIST; do
  ./branch-create.sh $REPO staging
done
