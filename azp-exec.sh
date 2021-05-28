# az devops login --organization=https://dev.azure.com/YOUR_ORG/
# az pipelines list  --detect --org=https://dev.azure.com/Teck/ --project=RACE21
# az pipelines run --branch $(git rev-parse --abbrev-ref HEAD) --detect --org=https://dev.azure.com/Teck/ --project=RACE21 --name=HCA-Dispatcher-Supervisor-Backend-Build --variables DEV_BUILD=true DEV_DEPLOY=true
az pipelines run --branch $(git rev-parse --abbrev-ref HEAD) --detect --org=https://dev.azure.com/Teck/ --project=RACE21 --name=HCA-Dispatcher-Supervisor-Backend-Build
