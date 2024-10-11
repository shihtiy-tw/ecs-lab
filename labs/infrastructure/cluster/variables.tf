variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "tf-ecs-lab"
}

variable "enable_container_insights" {
  description = "Whether to enable container insights"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to the ECS cluster"
  type        = map(string)
  default     = {}
}

variable "capacity_providers" {
  description = "List of short names of one or more capacity providers to associate with the cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "container_instances_capacity_provider" {
  description = "Name of the EC2 capacity provider to associate with the cluster"
  type        = string
  default     = null
}

variable "default_capacity_provider_strategy" {
  description = "The capacity provider strategy to use by default for the cluster"
  type = object({
    base              = number
    weight            = number
    capacity_provider = string
  })
  default = {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

