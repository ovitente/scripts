# az devops login --organization=https://dev.azure.com/YOUR_ORG/ --project=YOUR_PROJECT
# az pipelines list  --detect --org=https://dev.azure.com/Teck/ --project=RACE21
# az pipelines run --branch $(git rev-parse --abbrev-ref HEAD) --detect --org=https://dev.azure.com/Teck/ --project=RACE21 --name=HCA-Dispatcher-Supervisor-Backend-Build --variables DEV_DEPLOY=true --variables QA_BUILD=true --variables STAGE_BUILD=true
# az pipelines run --branch $(git rev-parse --abbrev-ref HEAD) --detect --org=https://dev.azure.com/Teck/ --project=RACE21 --name=HCA-Dispatcher-Supervisor-Backend-Build
az pipelines run --branch $(git rev-parse --abbrev-ref HEAD) --detect --org=https://dev.azure.com/Teck/ --project=RACE21 --name=HCA-Supervisor-Mobile-App-Build
