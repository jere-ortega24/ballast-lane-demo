resource "aws_eks_pod_identity_association" "aws_ebs_csi_driver" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  role_arn        = data.terraform_remote_state.ebs_csi_driver_iam.outputs.iam_role_arn
  service_account = "ebs-csi-controller-sa"
}

resource "aws_eks_pod_identity_association" "vpc_cni" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  role_arn        = data.terraform_remote_state.vpc_cni_iam.outputs.iam_role_arn
  service_account = "aws-node"
}

resource "aws_eks_pod_identity_association" "demo_api" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "demo"
  role_arn        = data.terraform_remote_state.demo_api_iam.outputs.iam_role_arn
  service_account = "demo-api"
}
