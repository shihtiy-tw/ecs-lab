output "private_auto_scaling_group_name" {
  description = "Name of the created private Auto Scaling Group"
  value       = aws_autoscaling_group.private-asg.name
}

output "public_auto_scaling_group_name" {
  description = "Name of the created public Auto Scaling Group"
  value       = aws_autoscaling_group.public-asg.name
}

output "launch_template_id" {
  description = "ID of the created launch template"
  value       = aws_launch_template.main.id
}

output "iam_instance_profile_name" {
  description = "Name of the created IAM instance profile"
  value       = aws_iam_instance_profile.ecs_container_instance_profile.name
}

output "iam_role_name" {
  description = "Name of the created IAM role"
  value       = aws_iam_role.ecs_container_instance_role.name
}
