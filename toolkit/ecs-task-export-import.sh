#!/bin/bash
# export the task def
# source: https://gist.github.com/pahud/9affaa353f52e734a638b1329f7ca3d0

family='TaskDefName'
aws ecs describe-task-definition --task-definition "$family" \
--query "taskDefinition.{family:family, taskRoleArn:taskRoleArn, executionRoleArn:executionRoleArn, networkMode:networkMode, containerDefinitions:containerDefinitions, volumes:volumes, placementConstraints:placementConstraints, requiresCompatibilities:requiresCompatibilities, cpu:cpu, memory:memory, tags:tags, pidMode:pidMode, ipcMode:ipcMode, proxyConfiguration:proxyConfiguration}" | jq 'del(.[] | nulls)' > "$family"-task-def.json

# # import the task def into newFamily task family
# $ aws ecs register-task-definition --cli-input-json file://taskDef.json --family newFamily

# # one-liner
# aws ecs describe-task-definition --task-definition $family \
# --query "taskDefinition.{family:family, taskRoleArn:taskRoleArn, executionRoleArn:executionRoleArn, networkMode:networkMode, containerDefinitions:containerDefinitions, volumes:volumes, placementConstraints:placementConstraints, requiresCompatibilities:requiresCompatibilities, cpu:cpu, memory:memory, tags:tags, pidMode:pidMode, ipcMode:ipcMode, proxyConfiguration:proxyConfiguration}" | jq 'del(.[] | nulls)' | xargs -0 aws ecs register-task-definition --family newFamily --cli-input-json

# convert the taskDef.json to taskDef.yaml
docker run -v "$PWD":/workdir mikefarah/yq -oy "$family"-task-def.json > "$family"-task-def.yaml
