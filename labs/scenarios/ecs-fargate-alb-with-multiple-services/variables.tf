# variable "aws_region" {
#   description = "AWS region"
#   type        = string
#   default     = terraform.workspace
# }

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "tf-ecs-lab-vpc"
}

# variable "public_subnet_cidrs" {
#   description = "List of CIDR blocks for public subnets"
#   type        = list(string)
# }
#
# variable "private_subnet_cidrs" {
#   description = "List of CIDR blocks for private subnets"
#   type        = list(string)
# }
#
# variable "availability_zones" {
#   description = "List of availability zones"
#   type        = list(string)
# }

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "tf-ecs-lab"
}


# variable "tags" {
#   description = "A map of tags to add to the ECS cluster"
#   type        = map(string)
# }

# Add variables for ALB and ECS service configuration here
variable "task_cpu" {
  description = "The number of cpu units used by the task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The amount (in MiB) of memory used by the task"
  type        = number
  default     = 512
}

variable "container_image" {
  description = "The container image to use for the service"
  type        = string
  default     = "nginx"
}

variable "service_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 2
}

