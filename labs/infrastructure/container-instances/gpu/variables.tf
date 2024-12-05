variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "tf-ecs-lab-vpc"
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
  default     = "tf-ecs-lab-gpu-asg"
}

# variable "subnet_ids" {
#   description = "List of subnet IDs for the Auto Scaling Group"
#   type        = list(string)
# }

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 0
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "launch_template_name" {
  description = "Name of the launch template"
  type        = string
  default     = "tf-ecs-lab-launch-template-gpu"
}

variable "container_instance_name" {
  description = "Name of the Container Instance"
  type        = string
  default     = "tf-ecs-lab-container-instance-gpu"
}

# variable "ami_id" {
#   description = "ID of the AMI to use for the EC2 instances"
#   type        = string
# }

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "g4dn.2xlarge"
}

# variable "security_group_ids" {
#   description = "List of security group IDs for the EC2 instances"
#   type        = list(string)
# }

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "tf-ecs-lab"
}
