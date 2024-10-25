data "aws_ami" "ecs_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = ""
}

variable "enable_container_insights" {
  description = "Whether to enable container insights"
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "List of short names of one or more capacity providers to associate with the cluster"
  type        = list(string)
}

variable "default_capacity_provider_strategy" {
  description = "The capacity provider strategy to use by default for the cluster"
  type = object({
    base              = number
    weight            = number
    capacity_provider = string
  })
}

variable "tags" {
  description = "A map of tags to add to the ECS cluster"
  type        = map(string)
}

variable "use_ec2_capacity_provider" {
  description = "Whether to use EC2 capacity provider"
  type        = bool
  default     = true
}

variable "ec2_instance_type" {
  description = "EC2 instance type for container instances"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 container instances"
  type        = string
  default     = ""
}

# Add variables for ALB and ECS service configuration here

