resource "aws_ecs_task_definition" "netshoot" {
  family                   = "${data.aws_ecs_cluster.cluster.cluster_name}-fargate-netshoot-${var.scenario_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_tasks_role.arn

  container_definitions = jsonencode([
    {
      name              = "netshoot"
      image             = var.container_image_netshoot
      memoryReservatino = 128
      essential         = true
      entrypoint        = ["sh", "-c"]
      command           = ["while true; do curl -I ${aws_lb.main.dns_name}; done"]
    }
  ])

  depends_on = [
    aws_lb.main
  ]
}

resource "aws_ecs_service" "service_netshoot" {
  name            = "${data.aws_ecs_cluster.cluster.cluster_name}-service-netshoot-${var.scenario_name}"
  cluster         = data.aws_ecs_cluster.cluster.arn
  task_definition = aws_ecs_task_definition.netshoot.arn
  # desired_count          = var.service_desired_count
  desired_count          = 1
  enable_execute_command = true
  launch_type            = "EC2"

  network_configuration {
    subnets         = data.aws_subnets.private_subnets.ids
    security_groups = [aws_security_group.alb.id]
  }
}
