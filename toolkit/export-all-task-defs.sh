#!/bin/bash

# Set the AWS region
export AWS_DEFAULT_REGION=us-east-1

# Get all task definition families as a JSON array
families_json=$(aws ecs list-task-definition-families --status ACTIVE --query 'families[]' --output json)

# Convert JSON array to bash array
readarray -t families_array < <(echo "$families_json" | jq -r '.[]')

# Loop through each family
for family in "${families_array[@]}"; do
  echo "Processing task definition family: $family"

  # Get the latest active revision for this family
  revision=$(aws ecs describe-task-definition --task-definition "$family" --query 'taskDefinition.revision' --output text)

  # Set the full task definition name
  task_def="${family}:${revision}"

  echo "Exporting task definition: $task_def"

  # Export the task definition
  aws ecs describe-task-definition --task-definition "$task_def" \
    --query "taskDefinition.{family:family, taskRoleArn:taskRoleArn, executionRoleArn:executionRoleArn, networkMode:networkMode, containerDefinitions:containerDefinitions, volumes:volumes, placementConstraints:placementConstraints, requiresCompatibilities:requiresCompatibilities, cpu:cpu, memory:memory, tags:tags, pidMode:pidMode, ipcMode:ipcMode, proxyConfiguration:proxyConfiguration}" | jq 'del(.[] | nulls)' >"$family"-task-def.json

  # Convert JSON to YAML
  docker run -v "$PWD":/workdir mikefarah/yq -oy "$family"-task-def.json >"$family"-task-def.yaml

  echo "Exported $task_def to ${family}-task-def.json and ${family}-task-def.yaml"
done

echo "All task definitions exported."
