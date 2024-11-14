# ECS-Lab Project

This project contains configurations for managing ECS clusters and related infrastructure.

## Structure

TBD

## Usage

Refer to the README files in each environment directory for specific instructions on how to use and deploy the configurations.

### Setup Clusters

```bash
$ terraform -chdir=./labs/infrastructure/cluster init .

# use workspace to seperate the region
$ terraform -chdir=./labs/infrastructure/cluster workspace new us-east-1

$ terraform -chdir=./labs/infrastructure/cluster plan
$ terraform -chdir=./labs/infrastructure/cluster apply
```

### Setup Basic Container Instance

```bash
$ terraform -chdir=.labs/infrastructure/container-instances/general init .

# use workspace to seperate the region
$ terraform -chdir=.labs/infrastructure/container-instances/general workspace new us-east-1

$ terraform -chdir=.labs/infrastructure/container-instances/general plan
$ terraform -chdir=.labs/infrastructure/container-instances/general apply
```

## Tool

Cost
https://github.com/infracost/infracost

Test
https://terratest.gruntwork.io/docs/getting-started/quick-start/

Summary
https://github.com/dineshba/tf-summarize

Diagram
https://github.com/patrickchugh/terravision
