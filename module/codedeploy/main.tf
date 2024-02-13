resource "aws_codedeploy_app" "dop_c02_codedeploy" {
  compute_platform = "ECS"
  name             = "dop_c02_codedeploy"
}

# resource "aws_codedeploy_deployment_group" "example" {
#   app_name               = aws_codedeploy_app.dop_c02_codedeploy.name
#   service_role_arn       = 
# }