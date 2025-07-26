terraform {
  required_providers { aws = { source="hashicorp/aws" version="~>4.0" } }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = var.cluster_prefix
  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24"]
  enable_nat_gateway = false
  tags = { Environment = var.env }
}
