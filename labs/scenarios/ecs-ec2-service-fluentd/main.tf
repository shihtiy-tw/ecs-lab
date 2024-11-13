provider "aws" {
  region = terraform.workspace
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-public-*"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-private-*"]
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = var.cluster_name
}

resource "aws_security_group" "ecs" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-ecs-with-fluentd-for-ecs-sg"
  description = "Security group of ECS for ECS and EFS"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 24224
    to_port     = 24224
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "netshoot" {
  family                   = "${data.aws_ecs_cluster.cluster.cluster_name}-ec2-netshoot"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  # task_role_arn            = aws_iam_role.ecs_task_exec_role.arn
  execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_tasks_role.arn

  container_definitions = jsonencode([
    {
      name      = "netshoot"
      image     = var.container_image
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      command = ["sleep", "10800"],
      logConfiguration = {
        logDriver = "fluentd",
        options = {
          fluentd-address = "${var.service_name}.${var.domain_name}",
          tag             = "netshoot"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "service" {
  name                   = "${data.aws_ecs_cluster.cluster.cluster_name}-service-netshoot"
  cluster                = data.aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.netshoot.arn
  desired_count          = var.service_desired_count
  enable_execute_command = true
  launch_type            = "EC2"

  network_configuration {
    subnets         = data.aws_subnets.private_subnets.ids
    security_groups = [aws_security_group.ecs.id]
  }
}

resource "aws_ecs_task_definition" "fluentd" {
  family                   = "${data.aws_ecs_cluster.cluster.cluster_name}-ec2-fluentd"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  # task_role_arn            = aws_iam_role.ecs_task_exec_role.arn
  execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_tasks_role.arn

  container_definitions = jsonencode([
    {
      name      = "netshoot"
      image     = var.container_image_fluentd
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 24224
          hostPort      = 24224
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "fluentd-service" {
  name                   = "${data.aws_ecs_cluster.cluster.cluster_name}-service-fluentd"
  cluster                = data.aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.fluentd.arn
  desired_count          = var.service_desired_count
  enable_execute_command = true
  launch_type            = "EC2"

  network_configuration {
    subnets         = data.aws_subnets.private_subnets.ids
    security_groups = [aws_security_group.ecs.id]
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.this.arn
    container_name = var.service_name
  }
}
