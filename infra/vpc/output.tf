output "vpc_id" {
  description = "VPC ID for region us-west-2"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC Cidr for region us-west-2"
  value       = aws_vpc.this.cidr_block
}

output "public_route_table_id" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for region us-west-2"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs for region us-west-2"
  value       = aws_subnet.private[*].id
}

output "cert_arn" {
  description = "ARN for the TLS certificate"
  value       = aws_acm_certificate.this.arn
}
