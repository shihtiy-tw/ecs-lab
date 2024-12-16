resource "aws_security_group" "ecs" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-ecs-sg-${var.scenario_name}"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${data.aws_ecs_cluster.cluster.cluster_name}-fargate-nginx-${var.scenario_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_tasks_role.arn

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

resource "aws_ecs_service" "main" {
  name                   = "${data.aws_ecs_cluster.cluster.cluster_name}-service-${var.scenario_name}"
  cluster                = data.aws_ecs_cluster.cluster.arn
  task_definition        = aws_ecs_task_definition.main.arn
  desired_count          = var.service_desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true


  network_configuration {
    subnets         = data.aws_subnets.private_subnets.ids
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "app"
    container_port   = 80
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 5
  min_capacity       = 0
  resource_id        = "service/${data.aws_ecs_cluster.cluster.cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_targettracking" {
  name               = "ECSServiceAverageCPUUtilization:${aws_appautoscaling_target.ecs_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
      # predefined_metric_type = "ECSServiceAverageMemoryUtilization"
      # predefined_metric_type = "ALBRequestCountPerTarget"
    }
    target_value = 50
  }
}
