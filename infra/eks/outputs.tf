output "repository_demo_api" {
  description = "Repository for the demo api"
  value       = aws_ecr_repository.demo_api.repository_url
}
