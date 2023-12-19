provider "aws" {
  region  = "us-east-1"
  version = "~> 5.30.0"
}

locals {
  environment = {
    default = "production"
    staging = "staging"
  }
  cidr_block = {
    default = "10.0.0.0/16"
    staging = "10.1.0.0/16"
  }
  services = ["orders", "users"]
}

module "networking" {
  source      = "./modules/networking"
  environment = local.environment[terraform.workspace]
  vpc_cidr    = local.cidr_block[terraform.workspace]
}

module "compute" {
  source          = "./modules/compute"
  vpc_id          = module.networking.vpc_id
  vpc_cidr        = local.cidr_block[terraform.workspace]
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  environment     = local.environment[terraform.workspace]
}

module "application" {
  source          = "./modules/application"
  vpc_id          = module.networking.vpc_id
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  environment     = local.environment[terraform.workspace]
  service_names   = local.services
}