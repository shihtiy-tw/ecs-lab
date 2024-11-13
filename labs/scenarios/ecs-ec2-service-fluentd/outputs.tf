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
  value       = aws_ecs_service.service_nginx.name
}

# Outputs for aws_service_discovery_private_dns_namespace
output "namespace_id" {
  description = "The ID of the private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.private.id
}

output "namespace_arn" {
  description = "The ARN of the private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.private.arn
}

output "namespace_hosted_zone" {
  description = "The ID of the hosted zone created by the private DNS namespace"
  value       = aws_service_discovery_private_dns_namespace.private.hosted_zone
}

# Outputs for aws_service_discovery_service
output "service_id" {
  description = "The ID of the service discovery service"
  value       = aws_service_discovery_service.fluentd.id
}

output "service_arn" {
  description = "The ARN of the service discovery service"
  value       = aws_service_discovery_service.fluentd.arn
}

output "service_discovery_name" {
  description = "The name of the service discovery service"
  value       = aws_service_discovery_service.fluentd.name
}

output "service_dns_config" {
  description = "The DNS configuration of the service"
  value       = aws_service_discovery_service.fluentd.dns_config
}


# Outputs for aws_service_discovery_service
output "service_id_nginx" {
  description = "The ID of the service discovery service"
  value       = aws_service_discovery_service.nginx.id
}

output "service_arn_nginx" {
  description = "The ARN of the service discovery service"
  value       = aws_service_discovery_service.nginx.arn
}

output "service_discovery_name_nginx" {
  description = "The name of the service discovery service"
  value       = aws_service_discovery_service.nginx.name
}

output "service_dns_config_nginx" {
  description = "The DNS configuration of the service"
  value       = aws_service_discovery_service.nginx.dns_config
}


