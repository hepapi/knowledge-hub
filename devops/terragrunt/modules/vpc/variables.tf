variable "azs" {
  type        = list(string)
  description = "A list of availability zones names or ids in the region"
}

variable "environment" {
  type        = string
  description = "Environment-Name"
}

variable "vpc_cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC."
}

variable "enable_nat_gateway" {
  default     = false
  type        = bool
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
}

variable "enable_vpn_gateway" {
  default     = false
  type        = bool
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
}

variable "private_subnets" {
  type        = list(string)
  description = "A list of private subnets inside the VPC"
}

variable "public_subnets" {
  type        = list(string)
  description = "A list of public subnets inside the VPC"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
}