# ECSタスク（Terraform）実行用ポリシー
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "ecs_task_execution_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "codebuild:*",
          "codecommit:*",
          "ecr:*",
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_exec_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.id
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

# ECSクラスタ
resource "aws_ecs_cluster" "dop_c02_ecs_cluster" {
  name = "dop_c02_ecs_cluster"
}

# CloudWatchロググループ
resource "aws_cloudwatch_log_group" "dop_c02_ecs_log_group" {
  name = "/ecs/dop_c02_ecs_log_group"
}

# ECSタスク定義
resource "aws_ecs_task_definition" "dop_c02_ecs_task" {
  family                   = "dop_c02"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "dop_c02_terraform"
      image     = "${var.ecr_repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.dop_c02_ecs_log_group.name
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
      command   = [
        "version"
      ]
    },
  ])
}

#
# VPC
# https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/what-is-amazon-vpc.html
resource "aws_vpc" "dop_c02_ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dop_c02"
  }
}

# VPCのサブネット（パブリック）
# https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/configure-subnets.html
resource "aws_subnet" "dop_c02_ecs_public_subnet" {
  vpc_id            = aws_vpc.dop_c02_ecs_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "dop_c02"
  }
}

# インターネットゲートウェイ
# https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/VPC_Internet_Gateway.html
resource "aws_internet_gateway" "dop_c02_ecs_internet_gateway" {
  vpc_id = aws_vpc.dop_c02_ecs_vpc.id
}

# ルートテーブル（パブリックサブネット用）
resource "aws_route_table" "dop_c02_ecs_public_route_table" {
  vpc_id = aws_vpc.dop_c02_ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dop_c02_ecs_internet_gateway.id
  }
}

# ルートテーブルの関連付け（パブリックサブネット）
resource "aws_route_table_association" "dop_c02_ecs_public_route_table_association" {
  subnet_id      = aws_subnet.dop_c02_ecs_public_subnet.id
  route_table_id = aws_route_table.dop_c02_ecs_public_route_table.id
}

# セキュリティグループ
resource "aws_security_group" "dop_c02_ecs_security_group" {
  name        = "dop_c02_ecs_security_group"
  description = "Security group for ECS tasks to allow communication with ECR"
  vpc_id      = aws_vpc.dop_c02_ecs_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dop_c02"
  }
}

# 856679706912.dkr.ecr.us-west-2.amazonaws.com/dop_c02_ecr:latest
