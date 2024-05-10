resource "aws_security_group" "k8s" {
  name        = "kubernetes-cluster-sg"
  description = "Kubernetes Cluster Firewall Rules"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name = "kubernetes-cluster-sg"
  }
}

resource "aws_security_group_rule" "out_allow_all_k8s" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s.id
}
