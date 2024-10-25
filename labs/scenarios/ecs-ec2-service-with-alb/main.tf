provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.cluster_name}-ecs-tasks"
  description = "Allow inbound traffic for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# TODO: Add ECS service resources here

