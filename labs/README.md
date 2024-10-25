
# ECS Lab

## Region

rely on the terraform workspace for region setting

```bash
$ terraform workspace list
$ terraform workspace new us-east-1
```

```terraform
provider "aws" {
  region = terraform.workspace
}
```
