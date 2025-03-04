# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Module Source
  base_source_url = "${path_relative_from_include()}/../modules"
  # base_source_url = "git::git@github.com:ABCSoftware/terraform-modules.git"

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  target_account = local.environment_vars.locals.aws_account_id
  target_region  = local.region_vars.locals.aws_region

  remote_state_account    = "123456789123" # Do not forget to change and enter your account ID !
  remote_state_lock_table = "terraform-state-locks"
  remote_state_bucket     = "terraform-state-${local.remote_state_region}-${local.remote_state_account}"
  remote_state_region     = "us-east-1"
}

# Generate an AWS provider block
generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.remote_state_region}"
}

provider "aws" {
  alias  = "target"
  region = "${local.target_region}"
  assume_role {
    role_arn     = "arn:aws:iam::${local.target_account}:role/TerraformExecutionRole"
    session_name = "terraform"
  }
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = local.remote_state_bucket
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.remote_state_region == null ? local.target_region : local.remote_state_region
    dynamodb_table = local.remote_state_lock_table
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.

inputs = merge(
  local.region_vars.locals,
  local.environment_vars.locals
)
