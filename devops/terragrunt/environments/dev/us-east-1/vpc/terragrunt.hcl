# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

locals {
  base_source_url = include.root.locals.base_source_url
  module_name     = "vpc"
  module_version  = "v0.0.1"
}

terraform {
  source = "${local.base_source_url}//${local.module_name}?ref=${local.module_version}"
}

inputs = {
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_cidr           = "10.0.0.0/16"
  enable_nat_gateway = false
  enable_vpn_gateway = false
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}