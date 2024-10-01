module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"
  providers = {
    aws = aws.target
  }

  name = "${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.tags
}