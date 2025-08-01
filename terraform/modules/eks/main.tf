# EKS Cluster with Advanced Configuration
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnets
  cluster_endpoint_public_access = false
  cluster_endpoint_private_access = true

  # OIDC Identity provider
  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }

  # Encryption configuration
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  # Logging configuration
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    general = {
      name = "general"
      
      instance_types = ["t3.medium"]
      
      min_size     = 1
      max_size     = 10
      desired_size = 3

      ami_type               = "AL2_x86_64"
      capacity_type          = "ON_DEMAND"
      disk_size              = 50
      force_update_version   = true

      labels = {
        role = "general"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "general"
          effect = "NO_SCHEDULE"
        }
      }

      tags = {
        ExtraTag = "general"
      }
    }

    spot = {
      name = "spot"
      
      instance_types = ["t3.medium", "t3a.medium", "t2.medium"]
      
      min_size     = 0
      max_size     = 5
      desired_size = 2

      ami_type      = "AL2_x86_64"
      capacity_type = "SPOT"
      disk_size     = 50

      labels = {
        role = "spot"
      }

      tags = {
        ExtraTag = "spot"
      }
    }
  }

  # Add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    aws-efs-csi-driver = {
      most_recent = true
    }
  }

  tags = var.tags
}

# KMS Key for EKS encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}
