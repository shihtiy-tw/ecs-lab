# Create EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "my-product"
}

# Create EFS Mount Target
resource "aws_efs_mount_target" "efs_mt" {
  count           = length(data.aws_subnets.private_subnets.ids)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = tolist(data.aws_subnets.private_subnets.ids)[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${data.aws_ecs_cluster.cluster.cluster_name}-ec2-with-efs-for-efs-sg"
  description = "Security group of EFS for ECS and EFS"
  vpc_id      = data.aws_vpc.vpc.id

  # https://docs.aws.amazon.com/efs/latest/ug/sg-information.html
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
