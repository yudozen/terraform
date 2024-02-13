# Dockerレジストリ
resource "aws_ecr_repository" "dop_c02_ecr" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

output "repository_url" {
  value = aws_ecr_repository.dop_c02_ecr.repository_url
}
