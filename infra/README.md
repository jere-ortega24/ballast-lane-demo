# Demo API Infrastructure
This repository contains the infrastructure to deploy the demo API.
It uses terraform for the AWS resources and helm for the kubernetes resources.

## AWS Resources
In general the AWS resources are the VPC, the EKS cluster, all the IAM Roles
required for the EKS cluster, the route53 DNS pointing to the ingress nginx.

Terraform is using an S3 backend to store the state file.

## Kubernetes Resources
The kuberentes resources managed by helm are the ingress nginx, the postgresql
database, and the GitLab agent for deployment from GitLab. Some basic resources
like the namespace and secrets are managed by plain yaml manifests.
