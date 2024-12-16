# Add ALB and ECS service resources here
resource "aws_security_group" "alb" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-alb-sg-${var.scenario_name}"
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
  name               = "${data.aws_ecs_cluster.cluster.cluster_name}-alb-${var.scenario_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public_subnets.ids
}

resource "aws_lb_target_group" "main" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-tg-${var.scenario_name}"
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
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
