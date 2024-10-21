output "vpc_id" {
  description = "The ID of the VPC"
  value       = data.aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = data.aws_subnets.public_subnets.ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = data.aws_subnets.private_subnets.ids
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = data.aws_ecs_cluster.cluster.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = data.aws_ecs_cluster.cluster.cluster_name
}

# output "alb_name" {
#   description = "Name of the ALB"
# }

# Codedeploy
output "codedeploy_app_id" {
  value       = try(aws_codedeploy_app.app.id, null)
  description = "The application ID."
}

output "codedeploy_app_name" {
  description = "The application's name."
  value       = try(aws_codedeploy_app.app.name, null)
}

output "codedeploy_group_id" {
  description = "The application group ID."
  value       = try(aws_codedeploy_deployment_group.group-az1.id, null)
}

output "codedeploy_group_arn" {
  description = "The application group ARN."
  value       = try(aws_codedeploy_deployment_group.group-az1.arn, null)
}

# output "deployment_config_name" {
#   value       = try(local.deployment_config_name, null)
#   description = "The deployment group's config name."
# }

# output "deployment_config_id" {
#   description = "The deployment config ID."
#   value       = try(local.deployment_config_id, null)
# }

# Parameter Store

output "parameter_names" {
  # Names are not sensitive
  value       = aws_ssm_parameter.main[0].name
  description = "A list of all of the parameter names"
}
