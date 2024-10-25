# TODO: copy the ecs on ec2 with efs for this
# Create EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "my-product"
}

# Create EFS Mount Target
resource "aws_efs_mount_target" "efs_mt" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.instance_sg.id]
}

# Create Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = aws_iam_role.ecs_task_exec_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn

  volume {
    name = "service-storage"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      root_directory = "/"
    }
  }

  container_definitions = <<DEFINITION
  [
    {
      "name": "netshoot",
      "image": "nicolaka/netshoot",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "mountPoints": [
        {
          "sourceVolume": "service-storage",
          "containerPath": "/mnt/efs"
        }
      ],
      "command": ["sleep", "3600"],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group" : "/ecs/service",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ]
  DEFINITION
}

# ECS Service with ECS Exec enabled
resource "aws_ecs_service" "service" {
  name                   = "service"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.task.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    assign_public_ip = false
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.instance_sg.id]
  }

  depends_on = [aws_efs_mount_target.efs_mt]
}

