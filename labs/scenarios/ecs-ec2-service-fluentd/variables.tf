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
  default     = "nicolaka/netshoot"
}

variable "container_image_fluentd" {
  description = "The container image to use for the service"
  type        = string
  default     = "fluent/fluentd:v1.17-debian-1"
}

variable "service_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "domain_name" {
  description = "The name of the private DNS namespace"
  type        = string
  default     = "local.internal"
}

variable "service_name" {
  description = "The name of the service discovery service"
  type        = string
  default     = "service-discovery"
}

variable "ttl" {
  description = "The TTL value for DNS records"
  type        = number
  default     = 300
}

variable "type" {
  description = "The type of DNS record (A or SRV)"
  type        = string
  default     = "A"
  validation {
    condition     = contains(["A", "SRV"], var.type)
    error_message = "Type must be either 'A' or 'SRV'."
  }
}

variable "routing_policy" {
  description = "The routing policy for the DNS records (MULTIVALUE or WEIGHTED)"
  type        = string
  default     = "MULTIVALUE"
  validation {
    condition     = contains(["MULTIVALUE", "WEIGHTED"], var.routing_policy)
    error_message = "Routing policy must be either 'MULTIVALUE' or 'WEIGHTED'."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


