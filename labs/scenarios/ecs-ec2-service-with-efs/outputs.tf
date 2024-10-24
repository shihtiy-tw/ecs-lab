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

output "efs_arn" {
  value       = aws_efs_file_system.efs.arn
  description = "EFS ARN"
}

output "efs_id" {
  value       = aws_efs_file_system.efs.id
  description = "EFS ID"
}

output "efs_dns_name" {
  value       = aws_efs_file_system.efs.dns_name
  description = "EFS DNS name"
}

output "mount_target_dns_names" {
  value       = coalescelist(aws_efs_mount_target.efs_mt[*].mount_target_dns_name, [""])
  description = "List of EFS mount target DNS names"
}

output "mount_target_ids" {
  value       = coalescelist(aws_efs_mount_target.efs_mt[*].id, [""])
  description = "List of EFS mount target IDs (one per Availability Zone)"
}

output "mount_target_ips" {
  value       = coalescelist(aws_efs_mount_target.efs_mt[*].ip_address, [""])
  description = "List of EFS mount target IPs (one per Availability Zone)"
}

output "network_interface_ids" {
  value       = coalescelist(aws_efs_mount_target.efs_mt[*].network_interface_id, [""])
  description = "List of mount target network interface IDs"
}

output "efs_security_group_id" {
  value       = aws_security_group.efs.id
  description = "EFS Security Group ID"
}

output "efs_security_group_arn" {
  value       = aws_security_group.efs.arn
  description = "EFS Security Group ARN"
}

output "security_group_name" {
  value       = aws_security_group.efs.name
  description = "EFS Security Group name"
}
