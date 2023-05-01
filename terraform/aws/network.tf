module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.tag_name}-network"
  cidr = var.vpc_cidr

  azs                = var.azs
  private_subnets    = var.private_subnets_cidr
  public_subnets     = var.public_subnets_cidr
  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}