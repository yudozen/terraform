# IAMポリシー作成
resource "aws_iam_policy" "codebuild_docker_policy" {
  name        = "CodeBuildDockerPolicy"
  description = "CodeBuild Docker build and push permissions"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:GitPull"
      ],
      "Resource": "${var.codecommit_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": "*"
    }  
  ]
}
EOF
}

resource "aws_iam_role" "codebuild_service_role" {
  name = "CodeBuildServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild_docker_policy_attachment" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = aws_iam_policy.codebuild_docker_policy.arn
}

resource "aws_codebuild_project" "dop_c02_codebuild" {
  name          = var.name
  description   = "dop-c02 codebuild"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild_service_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "us-west-2"
    }

    environment_variable {
      name  = "ECR_URI"
      value = var.ecr_repository_url
    }

    environment_variable {
      name  = "ORIGINAL_IMAGE_NAME"
      value = "hashicorp/terraform:1.7.2"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = var.codecommit_clone_url_http
    git_clone_depth = 1
  }

  source_version = "master"
}

# 出力
output "name" {
  value = aws_codebuild_project.dop_c02_codebuild.name
}
