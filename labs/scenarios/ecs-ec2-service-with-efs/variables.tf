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

variable "container_mount_points_source_volume" {
  description = "The container mount points to use for the EFS volume"
  type        = string
  default     = "efs-service-storage"
}

variable "container_mount_points_path" {
  description = "The container mount points to use for the EFS volume"
  type        = string
  default     = "/mnt/efs"
}

variable "service_desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}


# variable "blue_lb_target_group_name" {
#   type        = string
#   description = "Name of the blue target group."
# }
#
# variable "green_lb_target_group_name" {
#   type        = string
#   description = "Name of the green target group."
# }

variable "auto_rollback_enabled" {
  default     = true
  type        = string
  description = "Indicates whether a defined automatic rollback configuration is currently enabled for this Deployment Group."
}

variable "auto_rollback_events" {
  default     = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  type        = list(string)
  description = "The event type or types that trigger a rollback."
}

variable "action_on_timeout" {
  default     = "CONTINUE_DEPLOYMENT"
  type        = string
  description = "When to reroute traffic from an original environment to a replacement environment in a blue/green deployment."
}

variable "wait_time_in_minutes" {
  default     = 0
  type        = string
  description = "The number of minutes to wait before the status of a blue/green deployment changed to Stopped if rerouting is not started manually."
}

variable "termination_wait_time_in_minutes" {
  default     = 5
  type        = string
  description = "The number of minutes to wait after a successful blue/green deployment before terminating instances from the original environment."
}

variable "test_traffic_route_listener_arns" {
  default     = []
  type        = list(string)
  description = "List of Amazon Resource Names (ARNs) of the load balancer to route test traffic listeners."
}

variable "iam_name" {
  default     = "ecs-lab-codedeploy-app-iam-role"
  type        = string
  description = "Name for create the IAM Role"
}

variable "iam_path" {
  default     = "/"
  type        = string
  description = "Path in which to create the IAM Role and the IAM Policy."
}

variable "description" {
  default     = "Managed by Terraform"
  type        = string
  description = "The description of the all resources."
}

## SSM PARAMETER
variable "ssm_parameter_format" {
  description = "The output format for rendered AppSpec file to write to SSM. Can be `json` or `yaml`."
  default     = "json"
  type        = string

  validation {
    condition     = contains(["json", "yaml"], var.ssm_parameter_format)
    error_message = "Value must be `json` or `yaml`."
  }
}

variable "enable_ssm_parameter" {
  description = "Create an AWS SSM Parameter for the rendered AppSpec."
  default     = true
  type        = bool
}

variable "ssm_description" {
  description = "Description of the SSM Parameter."
  default     = null
  type        = string
}

variable "ssm_name" {
  description = "Name of the SSM Parameter."
  default     = "tf-ecs-lab-ssm-codedeploy-appspec"
  type        = string
}
