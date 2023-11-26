############ EKS AdminAccess IAM Entities ############
data "aws_iam_policy_document" "eks_admin_access_policy" {

  version = "2012-10-17"
  statement {
    sid    = "EksAdminAccessAllowPolicy"
    effect = "Allow"
    resources = [
      "arn:aws:eks:${var.region}:894213385675:cluster/${local.names.eks_cluster}"
    ]
    actions = [
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:AccessKubernetesApi",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:DescribeUpdate",
      "eks:ListUpdates",
      "eks:ListAddons",
      "eks:DescribeAddon",
      "eks:DescribeAddonVersions",
      "eks:DescribeFargateProfile",
      "eks:DescribeIdentityProviderConfig",
      "eks:ListFargateProfiles",
      "eks:ListIdentityProviderConfigs",
      "eks:ListTagsForResource"
    ]
  }
  # statement {
  #     sid         = "EksAdminAccessDenyPolicy"
  #     effect      = "Deny"
  #     resources   = [
  #         "*"
  #     ]
  #     actions     = [
  #         "secretsmanager:*"
  #     ]
  # }
  statement {
    sid    = "AssumeEksAdminAccessRole"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "${aws_iam_role.eks_admin_access_role.arn}"
    ]
  }
}

resource "aws_iam_role" "eks_admin_access_role" {

  name = "${local.names.eks_cluster}_eks-admin-access.role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Condition = {}
        Principal = {
          AWS = "arn:aws:iam::125378330806:root"
        }
      }
    ]
  })
}
