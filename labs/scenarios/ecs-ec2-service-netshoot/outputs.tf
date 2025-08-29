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

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.service.name
}

# output "alb_name" {
#   description = "Name of the ALB"
# }

# output "access_point_arns" {
#   value       = local.enabled ? { for arn in sort(keys(var.access_points)) : arn => aws_efs_access_point.default[arn].arn } : null
#   description = "EFS AP ARNs"
# }

# output "access_point_ids" {
#   value       = local.enabled ? { for id in sort(keys(var.access_points)) : id => aws_efs_access_point.default[id].id } : null
#   description = "EFS AP ids"
# }

