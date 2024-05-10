resource "aws_ecr_repository" "demo_api" {
  name                 = "demo-api"
  force_delete         = true
  image_tag_mutability = "MUTABLE"
}
