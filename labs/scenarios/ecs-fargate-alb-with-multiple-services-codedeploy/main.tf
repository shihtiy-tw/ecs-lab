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
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-alb-codedeploy-sg"
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
  name               = "${data.aws_ecs_cluster.cluster.cluster_name}-alb-codedeploy"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public_subnets.ids
}

resource "aws_lb_target_group" "tg-az-1-blue" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-az1-tg-blue"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_target_group" "tg-az-1-green" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-az1-tg-green"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = "ip"
}

resource "aws_lb_target_group" "tg-az-2" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-az2-tg-codedeploy"
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
        arn    = aws_lb_target_group.tg-az-1-blue.arn
        weight = 30
      }
      # If the listener assoicate with other targetgroup outside of the ECS service deployment, will get the error below when trigger Blue/Green codedeploy:
      # The ELB could not be updated due to the following error: Only target group in ECS deployment group (arn:aws:elasticloadbalancing:xxx:xxx:targetgroup/xxx, arn:aws:elasticloadbalancing:ooo:ooo:targetgroup/ooo) can be set on listener arn:aws:elasticloadbalancing:xxx:xxx:listener/xxx.
      #
      # An ECS service can only be created with an targetgroup associated with an ELB listener:
      # Error: creating ECS Service (tf-ecs-lab-service-az2-codedeploy): operation error ECS: CreateService, https response error StatusCode: 400, RequestID: xxx, InvalidParameterException: The target group with targetGroupArn arn:aws:elasticloadbalancing:xxx:xxx:targetgroup/xxx does not have an associated load balancer.
      # target_group {
      #   arn    = aws_lb_target_group.tg-az-2.arn
      #   weight = 30
      # }
    }
  }
}

# data "aws_ecr_repository" "nginx" {
#   name = "nginx"
# }

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
  name                   = "${data.aws_ecs_cluster.cluster.cluster_name}-service-az1-codedeploy"
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
    target_group_arn = aws_lb_target_group.tg-az-1-blue.arn
    container_name   = "app"
    container_port   = 80
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

resource "aws_ecs_service" "service-az2" {
  name                   = "${data.aws_ecs_cluster.cluster.cluster_name}-service-az2-codedeploy"
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

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

# CodeDeploy

# ECS AWS CodeDeploy IAM Role
# ref: https://github.com/tmknom/terraform-aws-codedeploy-for-ecs/tree/master
#
# https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/codedeploy_IAM_role.html

# https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "default" {
  name               = var.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  path               = var.iam_path
  description        = var.description
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

# https://www.terraform.io/docs/providers/aws/r/iam_policy.html
resource "aws_iam_policy" "default" {
  name        = var.iam_name
  policy      = data.aws_iam_policy_document.policy.json
  path        = var.iam_path
  description = var.description
}

data "aws_iam_policy_document" "policy" {
  # If the tasks in your Amazon ECS service using the blue/green deployment type require the use of
  # the task execution role or a task role override, then you must add the iam:PassRole permission
  # for each task execution role or task role override to the AWS CodeDeploy IAM role as an inline policy.
  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:CreateTaskSet",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:DeleteTaskSet",
      "cloudwatch:DescribeAlarms",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    resources = ["arn:aws:sns:*:*:CodeDeployTopic_*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:ModifyRule",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
    ]

    resources = ["arn:aws:lambda:*:*:function:CodeDeployHook_*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectMetadata",
      "s3:GetObjectVersion",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/UseWithCodeDeploy"
      values   = ["true"]
    }

    resources = ["*"]
  }
}

# https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html
resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.default.name
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_codedeploy_app" "app" {
  compute_platform = "ECS"
  name             = "ecs-fargate-alb-with-multiple-services-app"
}

resource "aws_codedeploy_deployment_group" "group-az1" {
  app_name = aws_codedeploy_app.app.name
  # https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html#deployment-configurations-predefined
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "ecs-alb-with-multiple-service-deploy-group-az1"
  service_role_arn       = aws_iam_role.default.arn

  auto_rollback_configuration {
    enabled = var.auto_rollback_enabled
    events  = var.auto_rollback_events
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = var.action_on_timeout
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = data.aws_ecs_cluster.cluster.cluster_name
    service_name = aws_ecs_service.service-az1.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.main.arn]
      }

      target_group {
        name = aws_lb_target_group.tg-az-1-blue.name
      }

      target_group {
        name = aws_lb_target_group.tg-az-1-green.name
      }
    }
  }
}


# Ref: https://github.com/geekcell/terraform-aws-ecs-codedeploy-appspec/blob/main/main.tf
locals {
  appspec = {
    version = 0.0
    Resources = [
      {
        TargetService = {
          Type = "AWS::ECS::Service"
          Properties = {
            TaskDefinition = aws_ecs_task_definition.main.arn

            LoadBalancerInfo = {
              ContainerName = tolist(aws_ecs_service.service-az1.load_balancer)[0].container_name
              ContainerPort = tolist(aws_ecs_service.service-az1.load_balancer)[0].container_port
            }

            PlatformVersion = aws_ecs_service.service-az1.platform_version

            #            NetworkConfiguration = {
            #              AwsvpcConfiguration = {
            #                Subnets        = aws_ecs_service.service-az1.network_configuration[0].subnets
            #                SecurityGroups = aws_ecs_service.service-az1.network_configuration[0].security_groups
            #                AssignPublicIp = aws_ecs_service.service-az1.network_configuration[0].assign_public_ip ? "ENABLED" : "DISABLED"
            #              }
            #            }
          }
        }
      }
    ]
  }
}

resource "aws_ssm_parameter" "main" {
  count = var.enable_ssm_parameter ? 1 : 0

  name        = var.ssm_name
  description = var.ssm_description
  type        = "String"
  value       = var.ssm_parameter_format == "json" ? jsonencode(local.appspec) : yamlencode(local.appspec)

  # tags = var.tags
}
