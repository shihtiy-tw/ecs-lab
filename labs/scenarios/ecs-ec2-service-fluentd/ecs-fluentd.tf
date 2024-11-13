
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
    registry_arn = aws_service_discovery_service.fluentd.arn
  }
}
