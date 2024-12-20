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

# Add ALB and ECS service resources here
resource "aws_security_group" "alb" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb" "main" {
  name               = "${data.aws_ecs_cluster.cluster.cluster_name}-alb-multiple-service"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public_subnets.ids
}

resource "aws_lb_target_group" "tg-az-1" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-az1-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_target_group" "tg-az-2" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-az2-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_target_group" "tg-az-3" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-az3-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.tg-az-1.arn
        weight = 30
      }
      target_group {
        arn    = aws_lb_target_group.tg-az-2.arn
        weight = 30
      }
      target_group {
        arn    = aws_lb_target_group.tg-az-3.arn
        weight = 30
      }
    }
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${data.aws_ecs_cluster.cluster.cluster_name}-fargate-nginx"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = jsonencode([
    {
      name      = "app"
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
    }
  ])
}

resource "aws_ecs_service" "service-az1" {
  name                   = "${data.aws_ecs_cluster.cluster.cluster_name}-service-az1"
  cluster                = data.aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.main.arn
  desired_count          = var.service_desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = [tolist(data.aws_subnets.private_subnets.ids)[0]]
    security_groups = [aws_security_group.alb.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg-az-1.arn
    container_name   = "app"
    container_port   = 80
  }
}

resource "aws_ecs_service" "service-az2" {
  name                   = "${data.aws_ecs_cluster.cluster.cluster_name}-service-az2"
  cluster                = data.aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.main.arn
  desired_count          = var.service_desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = [tolist(data.aws_subnets.private_subnets.ids)[1]]
    security_groups = [aws_security_group.alb.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg-az-2.arn
    container_name   = "app"
    container_port   = 80
  }
}

resource "aws_ecs_service" "service-az3" {
  name                   = "${data.aws_ecs_cluster.cluster.cluster_name}-service-az3"
  cluster                = data.aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.main.arn
  desired_count          = var.service_desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets         = [tolist(data.aws_subnets.private_subnets.ids)[2]]
    security_groups = [aws_security_group.alb.id]
  }
}

