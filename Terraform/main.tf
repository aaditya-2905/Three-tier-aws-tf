data "aws_caller_identity" "current" {}

module "vpc" {
  source = "github.com/aaditya-2905/Terraform-wrappers//wrappers/vpc-wrapper?ref=main"
  vpcs   = var.vpcs
}

data "aws_subnets" "primary_public" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_ids["primary"]]
  }
  filter {
    name   = "cidr-block"
    values = var.vpcs["primary"].public_subnet_cidr_blocks
  }
}

data "aws_subnets" "primary_private" {
  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_ids["primary"]]
  }
  filter {
    name   = "cidr-block"
    values = var.vpcs["primary"].private_subnet_cidr_blocks
  }
}

data "aws_subnets" "secondary_public" {
  provider = aws.secondary

  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_ids["secondary"]]
  }
  filter {
    name   = "cidr-block"
    values = var.vpcs["secondary"].public_subnet_cidr_blocks
  }
}

data "aws_subnets" "secondary_private" {
  provider = aws.secondary

  filter {
    name   = "vpc-id"
    values = [module.vpc.vpc_ids["secondary"]]
  }
  filter {
    name   = "cidr-block"
    values = var.vpcs["secondary"].private_subnet_cidr_blocks
  }
}

module "sg" {
  source = "github.com/aaditya-2905/Terraform-wrappers//wrappers/sg-wrapper?ref=main"

  sgs = {
    primary = {
      name        = "three-tier-primary-sg"
      description = "Security group for primary region"
      vpc_id      = module.vpc.vpc_ids["primary"]
      environment = "prod"

      ingress_rules = [
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { from_port = 3000, to_port = 3000, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = [var.vpcs["primary"].cidr_block] }
      ]

      egress_rules = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
      ]
    }

    secondary = {
      name        = "three-tier-secondary-sg"
      description = "Security group for secondary region"
      vpc_id      = module.vpc.vpc_ids["secondary"]
      environment = "prod"

      ingress_rules = [
        { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { from_port = 3000, to_port = 3000, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
        { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_blocks = [var.vpcs["secondary"].cidr_block] }
      ]

      egress_rules = [
        { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
      ]
    }
  }
}

module "alb_primary" {
  source = "github.com/aaditya-2905/Terraform-wrappers//wrappers/alb-wrapper?ref=main"

  name                       = var.primary_alb_name
  internal                   = var.primary_alb_internal
  environment                = var.primary_alb_environment
  vpc_id                     = module.vpc.vpc_ids["primary"]
  subnet_ids                 = data.aws_subnets.primary_public.ids
  sg_id                      = module.sg.sg_ids["primary"]
  enable_deletion_protection = false

  target_groups = var.primary_alb_target_groups
  listeners     = var.primary_alb_listeners
}

module "alb_secondary" {
  source = "github.com/aaditya-2905/Terraform-wrappers//wrappers/alb-wrapper?ref=main"

  aws_region                 = var.secondary_region
  name                       = var.secondary_alb_name
  internal                   = var.secondary_alb_internal
  environment                = var.secondary_alb_environment
  vpc_id                     = module.vpc.vpc_ids["secondary"]
  subnet_ids                 = data.aws_subnets.secondary_public.ids
  sg_id                      = module.sg.sg_ids["secondary"]
  enable_deletion_protection = false

  target_groups = var.secondary_alb_target_groups
  listeners     = var.secondary_alb_listeners
}

module "iam" {
  source = "github.com/aaditya-2905/Terraform-wrappers//wrappers/iam-wrapper?ref=main"

  roles              = var.iam_roles
  policies           = var.iam_policies
  policy_attachments = var.iam_policy_attachments
}

module "ecr" {
  source       = "github.com/aaditya-2905/Terraform-wrappers//wrappers/ecr-wrapper?ref=main"
  repositories = var.ecr_repositories
}

locals {
  # Dynamically inject the CI/CD image tag for the backend service
  processed_ecs_services = {
    for k, v in var.ecs_services : k => merge(v, {
      image = k == "backend" ? "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repositories["backend"].name}:${var.backend_image_tag}" : v.image
    })
  }
}

module "ecs" {
  source = "github.com/aaditya-2905/Terraform-wrappers//wrappers/ecs-wrapper?ref=main"

  clusters     = var.ecs_clusters
  ecs_services = local.processed_ecs_services
}

module "cloudfront" {
  source        = "github.com/aaditya-2905/Terraform-wrappers//wrappers/cloudfront-wrapper?ref=main"
  distributions = var.cloudfront_distributions
}

module "s3_frontend" {
  source = "github.com/aaditya-2905/Terraform-wrappers//wrappers/s3-wrapper?ref=main"

  bucket                 = var.s3_bucket_name
  force_destroy          = var.s3_force_destroy
  versioning             = var.s3_versioning
  cors_rule              = var.s3_cors_rule
  bucket_policy          = var.s3_bucket_policy
  public_access_block    = var.s3_public_access_block
  ownership_controls     = var.s3_ownership_controls
  acl                    = var.s3_acl
  server_side_encryption = var.s3_server_side_encryption
}

module "rds_global" {
  source = "./rds-global"

  providers = {
    aws           = aws
    aws.secondary = aws.secondary
  }

  primary_vpc_id   = module.vpc.vpc_ids["primary"]
  primary_subnets  = data.aws_subnets.primary_private.ids
  primary_vpc_cidr = var.vpcs["primary"].cidr_block
  primary_sg_id    = module.sg.sg_ids["primary"]

  secondary_vpc_id   = module.vpc.vpc_ids["secondary"]
  secondary_subnets  = data.aws_subnets.secondary_private.ids
  secondary_vpc_cidr = var.vpcs["secondary"].cidr_block
  secondary_sg_id    = module.sg.sg_ids["secondary"]
}
