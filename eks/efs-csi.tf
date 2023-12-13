resource "aws_security_group" "eks_shared_efs_sg" {
  count = contains(local.var.flags, "create_efs_storageclass") ? 1 : 0

  name        = "${local.names.eks_cluster}_eks-shared-efs-sg"
  description = "Allow traffic to access the EFS for nodes of the ${local.names.eks_cluster} cluster"
  vpc_id      = aws_vpc.eks_cluster[0].id

  ingress {
    description      = "NFS access"
    from_port        = 2049
    to_port          = 2049
    protocol         = "TCP"
    cidr_blocks      = [ format("%s.0.0/16", local.var.network.vpc.prefix_subnet) ]
  }
}

resource "aws_iam_role" "eks_node_efs_access_role" {
  count = contains(local.var.flags, "create_efs_storageclass") ? 1 : 0

  name = "${local.names.eks_cluster}_EFSCSIControllerIAM.role"
  assume_role_policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::166868639839:oidc-provider/${module.eks.oidc_provider}"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringEquals": {
              "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:${local.names.efs_csi_driver.service_account_name}"
            }
          }
        }
      ]
    }
  )

  inline_policy {
    name   = "${local.names.eks_cluster}_EFSCSIControllerIAM.policy"
    policy = jsonencode(
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Action": [
              "elasticfilesystem:DescribeAccessPoints",
              "elasticfilesystem:DescribeFileSystems",
              "elasticfilesystem:DescribeMountTargets",
              "ec2:DescribeAvailabilityZones"
            ],
            "Resource": "*"
          },
          {
            "Effect": "Allow",
            "Action": [
              "elasticfilesystem:CreateAccessPoint"
            ],
            "Resource": "*",
            "Condition": {
              "StringLike": {
                "aws:RequestTag/efs.csi.aws.com/cluster": "true"
              }
            }
          },
          {
            "Effect": "Allow",
            "Action": [
              "elasticfilesystem:TagResource"
            ],
            "Resource": "*",
            "Condition": {
              "StringLike": {
                "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
              }
            }
          },
          {
            "Effect": "Allow",
            "Action": "elasticfilesystem:DeleteAccessPoint",
            "Resource": "*",
            "Condition": {
              "StringEquals": {
                "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
              }
            }
          }
        ]
      }
    )
  }
}

# resource "kubernetes_service_account" "efs_csi_driver_sa" {
#   count = contains(local.var.flags, "create_efs_storageclass") ? 1 : 0

#   metadata {
#     name      = local.names.efs_csi_driver.service_account_name
#     namespace = local.const.kube_system_ns

#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.eks_node_efs_access_role[0].arn
#     }
#   }

#   automount_service_account_token = true

#   depends_on = [
#     # aws_iam_policy.eks_node_efs_policy
#     aws_iam_role.eks_node_efs_access_role
#   ]
# }

# BEGIN - EFS and CSI Driver Installation
resource "aws_efs_file_system" "eks_efs_storage" {
  count = contains(local.var.flags, "create_efs_storageclass") ? 1 : 0

  creation_token = "${local.names.eks_cluster}_eks-shared-efs"
}

resource "aws_efs_mount_target" "eks_efs_mount" {
    count           = contains(local.var.flags, "create_efs_storageclass") ? length(data.aws_availability_zones.current_region.names) : 0

    file_system_id  = aws_efs_file_system.eks_efs_storage[0].id
    #subnet_id       = element(aws_subnet.eks_private.*.id, count.index)
    subnet_id       = aws_subnet.eks_private[count.index].id

    security_groups = [aws_security_group.eks_shared_efs_sg[0].id]
}

resource "helm_release" "aws_efs_csi_driver" {
  count = contains(local.var.flags, "create_efs_storageclass") ? 1 : 0

  chart             = "aws-efs-csi-driver"
  repository        = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  name              = local.names.efs_csi_driver.name
  namespace         = "kube-system"
  version           = "2.4.5"
  reset_values      = true
  wait              = true

  set {
    name  = "image.repository"
    value = local.names.efs_csi_driver.image_repository
  }

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = local.names.efs_csi_driver.service_account_name
  }

    set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.eks_node_efs_access_role[0].arn}"
  }


  depends_on = [
    aws_efs_file_system.eks_efs_storage
  ]
}
# END - EFS CSI Driver Installation


# resource "kubernetes_annotations" "gp2" {
#   count = contains(local.var.flags, "create_efs_storageclass") ? 1 : 0

#   api_version = "storage.k8s.io/v1"
#   kind        = "StorageClass"
#   force       = "true"

#   metadata {
#     name = "gp2"
#   }

#   annotations = {
#     # Modify annotations to remove gp2 as default storage class still reatain the class
#     # "storageclass.kubernetes.io/is-default-class" = "false"

#     # Annotation to set gp3 as default storage class
#     "storageclass.kubernetes.io/is-default-class" = "true"
#   }

#   depends_on = [
#     aws_efs_file_system.eks_efs_storage
#   ]
# }

resource "kubernetes_storage_class_v1" "gp3" {
  # count = contains(local.var.flags, "create_efs_storageclass") ? 1 : 0

  metadata {
    name = "gp3"

    annotations = {
      # Annotation to set gp3 as default storage class
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    #encrypted = true
    # fsType    = "ext4"
    type      = "gp3"
  }

  depends_on = [
    aws_efs_file_system.eks_efs_storage
  ]
}

resource "kubernetes_storage_class_v1" "efs" {
  count = contains(local.var.flags, "create_efs_storageclass") ? 1 : 0

  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = aws_efs_file_system.eks_efs_storage[0].id
    directoryPerms   = "755"
    # gid              = "1001"
    # uid              = "1001"
  }

  depends_on = [
    aws_efs_file_system.eks_efs_storage
  ]
}