variable "name" {
  description = "プロジェクト名"
  type        = string
  default     = "dop_c02_codebuild"
}

variable "codecommit_arn" {
  type        = string
}

variable "codecommit_clone_url_http" {
  type        = string
}

variable "ecr_repository_url" {
  type        = string
}