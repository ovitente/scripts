#!/usr/bin/env bash

# Cherri-pick to master

echo -e "Script will applly git cherry-pick to all provided branches."

# branches=(dev-new qa-new stage-new qa stage master)
branches=($1)
[[ -z $branches ]] && { echo " Please provide branch as first argument."; exit 1; }

printf "%sEnter commit ID: "
read commmit_id
[[ -z $commmit_id ]] && { echo "Commit id is empty. Exit."; exit 1; }

echo "Branches to be proceeded: [ ${branches[@]} ] with commit ID [$commmit_id]"
read answer

# for branch in "${branches[@]}"; do
#   echo "$branch"
# done

for branch in "${branches[@]}"; do
  git checkout $branch
  git pull
  git cherry-pick $commmit_id
done

echo "Script finished."
