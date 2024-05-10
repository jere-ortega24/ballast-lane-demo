# Demo API
This demo is comprised by a few different parts.
1. The AWS infrastructure managed by terraform
2. The kubernetes resources managed by helm
3. The actual API built in Go
4. The CI pipelines using GitLab CI

## AWS Infrastructure
The base infrastructure uses a few different services.

The underlying VPC with public and private subnets, and all the required
resources to suppport it like route tables, nat gateways, etc...

The EKS cluster with a couple of node groups. There are also a few add-ons
provided by AWS installed, like the VPC CNI, the EBS CSI driver. These drivers
and other applications require permissions to create AWS resources and this is
provided by the Pod Identity Agent. In this case I took the opportunity to learn
it as I had not used it before. It's pretty straight forward, only thing is I
didn't find how to limit the assume policy to the specific cluster but it can be
limited in the permissions policies.

The route53 DNS configuration to provide access to the ingress nginx load balancer.

A TLS certificate generated usin ACM and validated via DNS.

## Kubernetes resources
These are managed with helm, there are a few basic things like the namespace,
some secrets, and the storage class created with plain yaml manifests.
Most resources are limited to specific node groups using the affinity
configuration. Also where possible I use a topology spread constraint to
ensure that replicas run on different availability zones.

The ingress nginx to provide http access to the API. This deploys an ELB and
uses a TLS certificate generated with AWS ACM. It has 3 replicas for high
availability.

The postgresql database backed by an EBS volume for persistence. The
configuration is provided via the values files and the passwords are provided
via a secret in a separate yaml manifest for security.

The GitLab agent to provide a way to deploy to the kubernetes cluster from
outside the VPC. Using this is more secure as there is no need to make the
kubernetes API public. The token is provided in a separate yaml manifest.
I had not had the opportunity to use this before so I take the time to learn.
Note: When configuring this noticed that in the project that manages the agents
if the project we are giving permssion doesn't exist yet the reference has to
be deleted and then recreated. Otherwise when trying to use it in the new
project it doesn't find the agent.

## The API
This a ver basic API built with Go and can be found in https://demo-api.ortega.tech .
I took the base of the project from [this post](https://deadsimplechat.com/blog/rest-api-with-golang-and-postgresql/)
and made some modifications to allow uploading images. The images are then
uploaded to an S3 bucket that has static web hosting configured with the
domain public.ortega.tech so that the images are publicly available.

The docker image after being built is pushed to an ECR repository.

The deployment is managed by helm too. It has 3 replicas. Uses a service
account and an IAM role to get access to the S3 bucket.

It also provides a docker compose file for ease of development. Details can be
found in the README of the project.

### Using API with curl
The API has 3 endpoints.
* `GET /albums` to list the albums. It also provides a link to the uploaded
    image, notice that the image URL is plain `http` instead of `https` as it
    is hosted in an S3 bucket.
* `POST /albums` to upload a new album.
* `GET /ping` used for health checks.

Create an album
```bash
cover_file=./your/album/image.jpg
json='{"id": 1, "title":"Above the Earth- Below the Sky", "artist":"If These Trees Could Talk", "price":5.9, "cover":"'$(base64 -w0 "$cover_file")'"}'
echo "$json" | curl -X POST -d @- https://demo-api.ortega.tech/albums
```

Get all albums. This will also give you the URL for the image uploaded.
```bash
curl https://demo-api.ortega.tech/albums
```

## CI
I took the liberty to upload this to GitLab too to do deployments using the GitLab CI.
* https://gitlab.com/jereortega24/ballast-lane-demo-infra
* https://gitlab.com/jereortega24/ballast-lane-demo-api
* https://gitlab.com/jereortega24/gitlab-agents

The pipeline logs can be found here:
* https://gitlab.com/jereortega24/ballast-lane-demo-infra/-/pipelines
* https://gitlab.com/jereortega24/ballast-lane-demo-api/-/pipelines

This uses a custom image with the necessary tools installed.
* helm
* kubectl
* terraform
* aws cli
* ecr credential helper
* docker cli

## User Story
We need to create a service to store information about music albums. It has
to be deployed to AWS using kubernetes, all the infrastructure has to be
managed with terraform and helm. Developers should be able to use CI
pipelines to deploy the service. The service will use PostgreSQL as its
database. The service will store the album covers and these will be stored
in an S3 bucket as a static web host for public access.

Tasks:
* [X] Create CI docker image
* [X] Create VPC using terraform
* [X] Create EKS using terraform
* [X] Configure GitLab agent
* [X] Create ingress nginx
* [X] Create PostgreSQL database
* [X] Create IAM Role for the service
* [X] Create CI pipeline
