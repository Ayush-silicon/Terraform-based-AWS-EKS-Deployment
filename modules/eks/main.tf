module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name    = "${var.cluster_prefix}-${var.env}"
  cluster_version = var.eks_version
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  node_groups = {
    default = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1
      instance_type    = "t3.micro"
    }
  }
  manage_aws_auth = true
  tags = { Environment = var.env }
}
