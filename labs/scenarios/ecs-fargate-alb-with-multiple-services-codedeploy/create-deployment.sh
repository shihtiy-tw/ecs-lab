#!/bin/bash

# The ARN to process
CODEDEPLOY_GROUP_ARN=$(terraform output codedeploy_group_arn)

# Extract the part after 'deploymentgroup:'
CODEDEPLOY_GROUP=${CODEDEPLOY_GROUP_ARN#*deploymentgroup:}

# PARAMETER_NAME
PARAMETER_NAME=$(terraform output parameter_names | tr -d '"')

# Split the deployment part into app name and group name
IFS='/' read -r APP_NAME GROUP_NAME <<< "${CODEDEPLOY_GROUP#\"}"

GROUP_NAME=$(sed -e 's/^"//' -e 's/"$//' <<<"$GROUP_NAME")
# PARAMETER_NAME=$(sed -e 's/^"//' -e 's/"$//' <<<"$PARAMETER_NAME")

# Print the results
echo "Application Name: $APP_NAME"
echo "Deployment Group Name: $GROUP_NAME"
echo "Parameter Name: $PARAMETER_NAME"

PARAMETER=$(aws ssm get-parameter --name "$PARAMETER_NAME" --query "Parameter.Value" --output json)
echo "$PARAMETER"
PARAMETER_SHA256=$(echo "$PARAMETER" | shasum -a 256)
echo "$PARAMETER_SHA256"

aws deploy create-deployment \
    --application-name "$APP_NAME" \
    --deployment-group-name "$GROUP_NAME" \
     --revision "{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": $PARAMETER}}" \
    --description "Deployment from Parameter Store AppSpec"


     #--revision "{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": $PARAMETER, \"sha256\": \"$PARAMETER_SHA256\"}}" \
    # --revision "{\"revisionType\": \"AppSpecContent\", \"appSpecContent\": {\"content\": $(aws ssm get-parameter --name "$PARAMETER_NAME" --query "Parameter.Value" --output json), \"sha256\": \"$(aws ssm get-parameter --name "$PARAMETER_NAME" --query "Parameter.Value" --output json | shasum -a 256 | cut -d' ' -f1)\"}}" \
