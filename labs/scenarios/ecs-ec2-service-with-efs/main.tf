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

# data "aws_ecr_repository" "nginx" {
#   name = "nginx"
# }

resource "aws_security_group" "ecs" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-ecs-with-efs-for-ecs-sg"
  description = "Security group of ECS for ECS and EFS"
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

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "${data.aws_ecs_cluster.cluster.cluster_name}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "netshoot" {
  family                   = "${data.aws_ecs_cluster.cluster.cluster_name}-ec2-netshoot"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  # task_role_arn            = aws_iam_role.ecs_task_exec_role.arn
  execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn

  volume {
    name = "efs-service-storage"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/"
      # transit_encryption      = "ENABLED"
      # transit_encryption_port = 2999
      # authorization_config {
      #   access_point_id = aws_efs_access_point.test.id
      #   iam             = "ENABLED"
      # }
    }
  }

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
      mountPoints = [
        {
          sourceVolume  = var.container_mount_points_source_volume,
          containerPath = var.container_mount_points_path
        }
      ],
      command = ["sleep", "10800"],
      # logConfiguration = {
      #   logDriver = "awslogs",
      #   options = {
      #     awslogs-group         = "/ecs/service",
      #     awslogs-region        = "us-east-1",
      #     awslogs-stream-prefix = "ecs"
      #   }
      # }
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "${data.aws_ecs_cluster.cluster.cluster_name}-service-efs"
  cluster         = data.aws_ecs_cluster.cluster.arn
  task_definition = aws_ecs_task_definition.netshoot.arn
  desired_count   = var.service_desired_count
  launch_type     = "EC2"

  network_configuration {
    subnets         = data.aws_subnets.private_subnets.ids
    security_groups = [aws_security_group.ecs.id]
  }
}
