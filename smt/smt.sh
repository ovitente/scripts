#!/usr/bin/env bash

# How it works
# 1. Go to tf outputs bucket and get values
# 2. Put plain values to the env files in x7-secrets
# 3. Put base64-ed values into yamled env values for github actions


CONFIG_PATH="$HOME/.x7-tools.conf"

ENV_FILE=""
ENV_FILE_WS=""
PROJECT_NAME="$(echo $1 | tr [:upper:] [:lower:])"
ENVIRONMENT_NAME="$(echo $2 | tr [:upper:] [:lower:])" 
TF_OUTPUT_FILE="outputs.yaml"

[[ -z $PROJECT_NAME ]] && echo "PROJECT_NAME is not set as first argument" && exit 1
[[ -z $ENVIRONMENT_NAME ]] && echo "ENVIRONMENT_NAME is not set as second argument" && exit 1

cat <<EOF

| PROJECT NAME = $PROJECT_NAME
| ENVIRONMENT  = $ENVIRONMENT_NAME
EOF

function JobInitMessage {
  local text="$1"
cat <<EOF

--------------------------------------------
 * $text
EOF

}

function SourceConfig {
  JobInitMessage "Sourcing x7 tools config"

  if [[ -f $CONFIG_PATH && ! -z $CONFIG_PATH ]]; then
    source $CONFIG_PATH 
    [ -d $ENV_FILES_PATH ] || { echo "Cant found directory [ $ENV_FILES_PATH ]. Please use x7sec.sh get. Denied."; exit 1; }
  else
    echo "$CONFIG_PATH was not found. Creating one. Please set proper path to x7-secrets directory." 
    echo 'ENV_FILES_PATH="$HOME/projects/Teck/x7-secrets"' > $CONFIG_PATH
  fi
}

function CheckRequirements {
  JobInitMessage "Checking requirements"

  commands=(gcloud gsutil docker fzf yq)
  local req_fail=0

  for i in "${commands[@]}"; do
    if ! [ -x "$(command -v $i)" ]; then
     echo "  | $i - not found.";
     req_fail=1
    fi
  done

  if [ $req_fail = 1 ]; then echo "Exit."; exit 1; fi
}

function SetTargetProject {
  JobInitMessage "Please choose proper project to access to"

  local projects project
  gcloud config set project $(gcloud projects list | fzf --height 50% --header-lines=1 --reverse --multi --cycle | awk '{print $1}')
}

function PullBucket {
  JobInitMessage "Downloading file from the bucket"

  mkdir -p bucket
  gsutil -q -m rsync -r gs://$PROJECT_NAME-$ENVIRONMENT_NAME-tf-state bucket
}

function GetAndParsePlainValues {
  JobInitMessage "Getting plain values from unhashed file.
   Make sure that variables in terraform output is equal to values in gh actions workflow."

  mv bucket/$TF_OUTPUT_FILE .

export ACTIONS_AND_DISMISSALS_PUBSUB_SUBSCRIPTION=$(yq r $TF_OUTPUT_FILE actions_and_dismissals_pubsub_subscription)
export ACTIONS_AND_DISMISSALS_PUBSUB_TOPIC=$(yq r $TF_OUTPUT_FILE actions_and_dismissals_pubsub_topic)
# export =$(yq r $TF_OUTPUT_FILE airflow_bucket)
# export =$(yq r $TF_OUTPUT_FILE airflow_cluster)
export DB_HOST=$(yq r $TF_OUTPUT_FILE db_host)
export DB_USER=$(yq r $TF_OUTPUT_FILE db_user)
export DB_PASSWORD=$(yq r $TF_OUTPUT_FILE db_password) 
export EVENTS_PUBSUB_SUBSCRIPTION=$(yq r $TF_OUTPUT_FILE events_pubsub_subscription)

#   cat <<EOF
#   ----------------------------------------------------------------------------------------------------
#   | DB_USER        = $DB_USER
#   | DB_PASSWORD    = $DB_PASSWORD
#   | DB_HOST = $DB_HOST
#   ----------------------------------------------------------------------------------------------------
# EOF
}

function PutValuesIntoEnvFiles {
  JobInitMessage " - Updating values for [ API ] on [ $ENVIRONMENT_NAME ]" 
  cd $ENV_FILES_PATH/$PROJECT_NAME/env-files/
  cp $ENVIRONMENT_NAME ${ENVIRONMENT_NAME}_edited

  awk \
    -v user="$DB_USER"  \
    -v password="$DB_PASSWORD" \
    -v host="$DB_HOST" \
    -v pubsub_topic="$ACTIONS_AND_DISMISSALS_PUBSUB_TOPIC" \
    '{sub(/DB_USER=.*/,"DB_USER="user)}1 \
    {sub(/DB_PASSWORD=.*/,"DB_PASSWORD="password)}1 \
    {sub(/DB_HOST=.*/,"DB_HOST=/cloudsql/"host)}1 \
    {sub(/ACTIONS_AND_DISMISSALS_PUBSUB_TOPIC=.*/,"ACTIONS_AND_DISMISSALS_PUBSUB_TOPIC="pubsub_topic)}1 \
    ' ${ENVIRONMENT_NAME}_edited > $ENVIRONMENT_NAME

  rm ${ENVIRONMENT_NAME}_edited

#------------------------------
  JobInitMessage " - Updating values for [ WS ] on [ $ENVIRONMENT_NAME ]" 
  cd $ENV_FILES_PATH/$PROJECT_NAME/env-files/ws_config
  cp $ENVIRONMENT_NAME ${ENVIRONMENT_NAME}_edited
  awk \
    -v user="$DB_USER"  \
    -v password="$DB_PASSWORD" \
    -v host="$DB_HOST" \
    -v pubsub_subscription="$ACTIONS_AND_DISMISSALS_PUBSUB_SUBSCRIPTION" \
    -v pubsub_events_subscription="$EVENTS_PUBSUB_SUBSCRIPTION" \
    '{sub(/DB_USER=.*/,"DB_USER="user)}1 \
    {sub(/DB_PASSWORD=.*/,"DB_PASSWORD="password)}1 \
    {sub(/DB_HOST=.*/,"DB_HOST=/cloudsql/"host)}1 \
    {sub(/ACTIONS_AND_DISMISSALS_PUBSUB_SUBSCRIPTION=.*/,"ACTIONS_AND_DISMISSALS_PUBSUB_SUBSCRIPTION="pubsub_subscription)}1 \
    {sub(/EVENTS_PUBSUB_SUBSCRIPTION=.*/,"EVENTS_PUBSUB_SUBSCRIPTION="pubsub_events_subscription)}1 \
    ' ${ENVIRONMENT_NAME}_edited > $ENVIRONMENT_NAME

  rm ${ENVIRONMENT_NAME}_edited
}

function PutValuesIntoGHActionsFiles {
  echo "  - Updating secrethub yamles for [ $ENVIRONMENT_NAME ]"
  cd $ENV_FILES_PATH/secrethub
  local env_name=$(echo $ENVIRONMENT_NAME | tr [:lower:] [:upper:])

  ENV_FILE="$(base64 $ENV_FILES_PATH/$PROJECT_NAME/env-files/$ENVIRONMENT_NAME)"
  ENV_FILE_WS="$(base64 $ENV_FILES_PATH/$PROJECT_NAME/env-files/ws_config/$ENVIRONMENT_NAME)"
  GCP_SA_KEY="$(base64 $ENV_FILES_PATH/$PROJECT_NAME/key-file/${ENVIRONMENT_NAME}.json)"

  yq w -i $PROJECT_NAME-back.yaml *.${env_name}_ENV_FILE $ENV_FILE
  yq w -i $PROJECT_NAME-back.yaml *.${env_name}_ENV_FILE_WS $ENV_FILE_WS
  yq w -i $PROJECT_NAME-back.yaml *.${env_name}_GCP_SA_KEY $GCP_SA_KEY

  yq w -i $PROJECT_NAME-ui.yaml *.${env_name}_GCP_SA_KEY $GCP_SA_KEY
  yq w -i $PROJECT_NAME-airflow.yaml *.${env_name}_GCP_SA_KEY $GCP_SA_KEY
}

function PushSecretsToGithubActions {
  echo "Should i push secrets to GitHub Actions? [N/y]"
  local answer
  read answer
  [[ -z $answer || $answer != y ]] && echo "Operation canceled." && ScriptComplete && exit 0

  cd $ENV_FILES_PATH/secrethub
    if ! [ -x "$(command -v secrethub)" ]; then
      echo "  | Local command secrethub not found. Using docker version instead."
      # alias secrethub='docker run --rm -it -e GITHUB_ACCESS_TOKEN -v $PWD:/app dannyben/secrethub'
      docker run --rm -it -e GITHUB_ACCESS_TOKEN -v $PWD:/app dannyben/secrethub bulk save $PROJECT_NAME-back.yaml 
      docker run --rm -it -e GITHUB_ACCESS_TOKEN -v $PWD:/app dannyben/secrethub bulk save $PROJECT_NAME-ui.yaml 
    else
      secrethub bulk save $PROJECT_NAME-back.yaml 
      secrethub bulk save $PROJECT_NAME-ui.yaml 
      secrethub bulk save $PROJECT_NAME-airflow.yaml 
    fi
  echo "  | Pushing secrets to GitHub Actions secrets is complete."
}

function RemoveTemp {
  JobInitMessage "Removing temporary files"
  rm -rvf bucket $TF_OUTPUT_FILE
}


function ScriptComplete {
  JobInitMessage "Job is complete"
}

# ----------------------------------------------------------------------------------------------------

SourceConfig
# CheckRequirements
RemoveTemp
# SetTargetProject
PullBucket
GetAndParsePlainValues
PutValuesIntoEnvFiles
PutValuesIntoGHActionsFiles
PushSecretsToGithubActions
# RemoveTemp
ScriptComplete
