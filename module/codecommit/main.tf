# gitリポジトリ
resource "aws_codecommit_repository" "dop_c02_01" {
  repository_name = var.repository_name
  description     = "DOP-C02用リポジトリ"
}

# IAMグループ
resource "aws_iam_group" "dop_c02-code_commit-group" {
  name = "dop_c02-code_commit-group"
}

# IAMグループへポリシーアタッチ
resource "aws_iam_group_policy_attachment" "codecommit_power_user" {
  group      = aws_iam_group.dop_c02-code_commit-group.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitPowerUser"
}

# IAMユーザー
resource "aws_iam_user" "dop_c02-code_commit-iam_user" {
  name = "dop_c02-code_commit-iam_user"
}

# IAMグループへの追加
resource "aws_iam_group_membership" "dop_c02-group_membership" {
  name = "dop_c02-group_membership"

  users = [
    aws_iam_user.dop_c02-code_commit-iam_user.name
  ]
  group = aws_iam_group.dop_c02-code_commit-group.name
}

# 認証情報を生成する
resource "aws_iam_service_specific_credential" "dop_c02-code_commit-cred" {
  service_name = "codecommit.amazonaws.com"
  user_name = aws_iam_user.dop_c02-code_commit-iam_user.name
}

# 認証情報を出力する
resource "local_sensitive_file" "codecommit_git_credentials_file" {
  content = <<EOF
Username: ${aws_iam_service_specific_credential.dop_c02-code_commit-cred.service_user_name}
Password: ${aws_iam_service_specific_credential.dop_c02-code_commit-cred.service_password}
EOF
  filename = "${path.module}/codecommit_credentials.txt"
}

# 出力
output "arn" {
  value = aws_codecommit_repository.dop_c02_01.arn
}

output "repository_name" {
  value = aws_codecommit_repository.dop_c02_01.repository_name
}

output "clone_url_http" {
  value = aws_codecommit_repository.dop_c02_01.clone_url_http
}