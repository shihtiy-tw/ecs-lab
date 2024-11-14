provider "aws" {
  region = terraform.workspace
}

data "aws_ami" "ecs_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-private-*"]
  }
}

# data "aws_subnets" "public_subnets" {
#   filter {
#     name   = "tag:Name"
#     values = ["${var.vpc_name}-public-*"]
#   }
# }

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

resource "aws_autoscaling_group" "private-asg" {
  name                = "${var.asg_name}-private-placement"
  vpc_zone_identifier = data.aws_subnets.private_subnets.ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.asg_name}-private"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "main" {
  name                   = var.launch_template_name
  image_id               = data.aws_ami.ecs_optimized.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_container_instance_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    cluster_name = var.cluster_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-instance"
    }
  }
}

resource "aws_iam_instance_profile" "ecs_container_instance_profile" {
  name = "${var.cluster_name}-ecs-agent-placement"
  role = aws_iam_role.ecs_container_instance_role.name
}

resource "aws_iam_role" "ecs_container_instance_role" {
  name = "${var.cluster_name}-ecs-agent-placement"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_container_instance_role" {
  role       = aws_iam_role.ecs_container_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# Instances Security Group
resource "aws_security_group" "instance_sg" {
  name        = "tf-ecs-lab-container-instance-placement-security-group"
  description = "Allow all traffic from ALB security group"
  vpc_id      = data.aws_vpc.vpc.id
}

resource "aws_security_group_rule" "instance_sg_allow_from_instance" {
  security_group_id = aws_security_group.instance_sg.id

  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instance_sg.id
}

resource "aws_security_group_rule" "instance_sg_allow_to_all" {
  security_group_id = aws_security_group.instance_sg.id

  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
