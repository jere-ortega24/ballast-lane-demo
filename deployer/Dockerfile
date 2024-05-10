from amazonlinux:2023.4.20240416.0

ENV HELM_VERSION=3.14.2
ENV TERRAFORM_VERSION=1.8.2-1
ENV KUBECTL_VERSION=1.29.4-150500.2.1

RUN dnf install -y \
    amazon-ecr-credential-helper \
    awscli-2 \
    docker \
    jq \
    shadow-utils \
    tar \
    wget \
    yum-utils \
  && dnf clean all

COPY kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN dnf install -y \
    kubectl-$KUBECTL_VERSION

RUN yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo \
  && dnf install -y terraform-$TERRAFORM_VERSION \
  && dnf clean all

RUN cd /tmp \
  && wget https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz \
  && tar -zxvf helm-v$HELM_VERSION-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && rm -rf helm-v$HELM_VERSION-linux-amd64.tar.gz linux-amd64

COPY docker-config.json /root/.docker/config.json
