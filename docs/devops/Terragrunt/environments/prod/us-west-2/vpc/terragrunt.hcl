# Include the root 'terragrunt.hcl" configuration. The root configuration contains settings that are common accross all
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
  azs                = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_cidr           = "10.3.0.0/16"
  enable_nat_gateway = false
  enable_vpn_gateway = false
  private_subnets    = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
  public_subnets     = ["10.3.101.0/24", "10.3.102.0/24", "10.3.103.0/24"]
  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}