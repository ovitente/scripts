#!/usr/bin/env bash
# New branch crator from source branch
# USAGE: branch-create.sh <REPO NAME> <SOURCE BRANCH NAME> <TARGET BRANCH NAME>
source ~/.gasm/gasm.conf

SOURCE_BRANCH_NAME=$2
TARGET_BRANCH_NAME=$3
SOURCE_BRANCH_SHA=""

function GetSecrets {
  [ -z "$PERSONAL_TOKEN" ] && echo "PERSONAL_TOKEN is Empty" && exit 1
}

function GetBranchSha {
  echo -e "\n ---------- [ $REPO_NAME ]---------- \n "
  echo "[ $REPO_OWNER $REPO_NAME $SOURCE_BRANCH_NAME ]"

  SOURCE_BRANCH_SHA=$(curl -s -L -X GET https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/git/refs/heads/$SOURCE_BRANCH_NAME -H "Authorization: Bearer $PERSONAL_TOKEN" -H "Content-Type: application/json" | jq -r '.object.sha')

  echo "BRANCH SHA=[ $SOURCE_BRANCH_SHA ]"
}

function ModRepo {
  curl -s -L -X POST https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/git/refs \
    -H "Authorization: Bearer $PERSONAL_TOKEN" \
    -H "Content-Type: application/json" \
    -d  @- <<EOF
{
    "ref": "refs/heads/$TARGET_BRANCH_NAME",
    "sha": "$SOURCE_BRANCH_SHA"
}
EOF

}

function DeleteBranch {
  echo -e "\n ---------- [ $REPO_NAME ]---------- \n $SOURCE_BRANCH_NAME"

  TARGET_BRANCH_NAME=$SOURCE_BRANCH_NAME

  curl -u ovitente:$PERSONAL_TOKEN -X DELETE \
  https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/git/refs/heads/$TARGET_BRANCH_NAME
}

# ------ MAIN ------ #

GetSecrets
GetBranchSha
# ModRepo
DeleteBranch
