variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary region for failover"
  type        = string
  default     = "ap-south-1"
}

variable "vpcs" {
  description = "Map of VPC configurations consumed by the vpc-wrapper"
  type = map(object({
    name                       = string
    cidr_block                 = string
    public_subnet_cidr_blocks  = optional(list(string), [])
    private_subnet_cidr_blocks = optional(list(string), [])
    availability_zones         = optional(list(string), [])
    enable_nat_gateway         = optional(bool, false)
    single_nat_gateway         = optional(bool, false)
    enable_dns_hostnames       = optional(bool, true)
    enable_dns_support         = optional(bool, true)
    tags                       = optional(map(string), {})
  }))

  default = {
    primary = {
      name                       = "three-tier-primary"
      cidr_block                 = "10.0.0.0/16"
      public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24"]
      private_subnet_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
      availability_zones         = ["us-east-1a", "us-east-1b"]
      enable_nat_gateway         = false
      single_nat_gateway         = false
      tags                       = { environment = "prod", region = "primary" }
    }
    secondary = {
      name                       = "three-tier-secondary"
      cidr_block                 = "10.1.0.0/16"
      public_subnet_cidr_blocks  = ["10.1.1.0/24", "10.1.2.0/24"]
      private_subnet_cidr_blocks = ["10.1.3.0/24", "10.1.4.0/24"]
      availability_zones         = ["ap-south-1a", "ap-south-1b"]
      enable_nat_gateway         = false
      single_nat_gateway         = false
      tags                       = { environment = "prod", region = "secondary" }
    }
  }
}

variable "sgs" {
  description = "Map of Security Group configurations consumed by the sg-wrapper"
  type = map(object({
    name        = string
    description = optional(string)
    vpc_id      = string
    environment = optional(string, "prod")
    ingress_rules = optional(list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = optional(list(string))
      security_groups = optional(list(string))
    })))
    egress_rules = optional(list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
    })))
    tags = optional(map(string))
  }))
  default = {}
}

variable "primary_alb_name" {
  description = "Name of the primary ALB"
  type        = string
  default     = "three-tier-primary-alb"
}

variable "primary_alb_internal" {
  description = "Whether the primary ALB is internal"
  type        = bool
  default     = false
}

variable "primary_alb_environment" {
  description = "Environment tag for the primary ALB"
  type        = string
  default     = "prod"
}

variable "primary_alb_target_groups" {
  description = "Target group config for primary ALB"
  type = map(object({
    port                 = optional(number, 80)
    protocol             = optional(string, "HTTP")
    target_type          = optional(string, "ip")
    deregistration_delay = optional(number, 300)
    health_check = optional(object({
      enabled             = optional(bool, true)
      interval            = optional(number, 30)
      path                = optional(string, "/api/health")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string, "200")
    }), {})
  }))
  default = {
    backend = {
      port        = 3000
      protocol    = "HTTP"
      target_type = "ip"
      health_check = {
        path    = "/api/health"
        matcher = "200"
      }
    }
  }
}

variable "primary_alb_listeners" {
  description = "Listener config for primary ALB"
  type = map(object({
    port             = optional(number, 80)
    protocol         = optional(string, "HTTP")
    target_group_key = string
    ssl_policy       = optional(string)
    certificate_arn  = optional(string)
  }))
  default = {
    http = {
      port             = 80
      protocol         = "HTTP"
      target_group_key = "backend"
    }
  }
}

variable "secondary_alb_name" {
  description = "Name of the secondary ALB"
  type        = string
  default     = "three-tier-secondary-alb"
}

variable "secondary_alb_internal" {
  description = "Whether the secondary ALB is internal"
  type        = bool
  default     = false
}

variable "secondary_alb_environment" {
  description = "Environment tag for the secondary ALB"
  type        = string
  default     = "prod"
}

variable "secondary_alb_target_groups" {
  description = "Target group config for secondary ALB"
  type = map(object({
    port                 = optional(number, 80)
    protocol             = optional(string, "HTTP")
    target_type          = optional(string, "ip")
    deregistration_delay = optional(number, 300)
    health_check = optional(object({
      enabled             = optional(bool, true)
      interval            = optional(number, 30)
      path                = optional(string, "/api/health")
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "HTTP")
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      matcher             = optional(string, "200")
    }), {})
  }))
  default = {
    backend = {
      port        = 3000
      protocol    = "HTTP"
      target_type = "ip"
      health_check = {
        path    = "/api/health"
        matcher = "200"
      }
    }
  }
}

variable "secondary_alb_listeners" {
  description = "Listener config for secondary ALB"
  type = map(object({
    port             = optional(number, 80)
    protocol         = optional(string, "HTTP")
    target_group_key = string
    ssl_policy       = optional(string)
    certificate_arn  = optional(string)
  }))
  default = {
    http = {
      port             = 80
      protocol         = "HTTP"
      target_group_key = "backend"
    }
  }
}

variable "iam_roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    assume_role_policy = string
    description        = optional(string, null)
    path               = optional(string, "/")
    tags               = optional(map(string), {})
  }))
  default = {
    ecs_task_execution_role = {
      assume_role_policy = <<-POLICY
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": { "Service": "ecs-tasks.amazonaws.com" },
              "Action": "sts:AssumeRole"
            }
          ]
        }
      POLICY
      description        = "ECS task execution role"
    }
    ecs_task_role = {
      assume_role_policy = <<-POLICY
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": { "Service": "ecs-tasks.amazonaws.com" },
              "Action": "sts:AssumeRole"
            }
          ]
        }
      POLICY
      description        = "ECS task role"
    }
  }
}

variable "iam_policies" {
  description = "Map of IAM policies to create"
  type = map(object({
    policy_document = string
    description     = optional(string, null)
    path            = optional(string, "/")
    tags            = optional(map(string), {})
  }))
  default = {}
}

variable "iam_policy_attachments" {
  description = "Attach policies to roles/users. Format: 'role:role_name:policy_arn'"
  type        = list(string)
  default = [
    "role:ecs_task_execution_role:arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "role:ecs_task_execution_role:arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

variable "ecr_repositories" {
  description = "Map of ECR repository configurations"
  type = map(object({
    name                  = string
    repository_type       = optional(string, "private")
    force_delete          = optional(bool, false)
    encryption_config     = optional(any)
    image_scanning_config = optional(any)
    repository_policy     = optional(string)
    lifecycle_policy      = optional(string)
    region                = optional(string)
    tags                  = optional(map(string), {})
  }))
  default = {
    backend = {
      name         = "three-tier-backend"
      force_delete = true
      image_scanning_config = {
        scan_on_push = true
      }
      tags = { service = "backend" }
    }
  }
}

variable "ecs_clusters" {
  description = "Map of ECS cluster configurations"
  type = map(object({
    name                      = string
    capacity_providers        = optional(list(string), ["FARGATE"])
    default_capacity_provider = optional(string, "FARGATE")
    container_insights        = optional(string, "disabled")
    enable_execute_command    = optional(bool, false)
    setting                   = optional(string, "containerInsights")
    tags                      = optional(map(string), {})
  }))
  default = {
    primary = {
      name               = "three-tier-primary"
      container_insights = "enabled"
      tags               = { region = "primary" }
    }
    secondary = {
      name               = "three-tier-secondary"
      container_insights = "enabled"
      tags               = { region = "secondary" }
    }
  }
}

variable "ecs_services" {
  description = "Map of ECS service and task definitions"
  type = map(object({
    cluster_name                   = string
    service_name                   = string
    task_family                    = string
    container_name                 = string
    image                          = string
    cpu                            = optional(string, "256")
    memory                         = optional(string, "512")
    port_mappings                  = optional(any)
    execution_role_arn             = optional(string)
    task_role_arn                  = optional(string)
    network_mode                   = optional(string, "awsvpc")
    subnets                        = optional(list(string), [])
    security_groups                = optional(list(string), [])
    assign_public_ip               = optional(bool, false)
    desired_count                  = optional(number, 1)
    launch_type                    = optional(string, "FARGATE")
    deployment_min_healthy_percent = optional(number, 100)
    deployment_max_percent         = optional(number, 200)
    target_group_arn               = optional(string)
    container_port                 = optional(number)
    log_group_name                 = optional(string)
    log_region                     = optional(string)
    environment_variables          = optional(any)
    secrets                        = optional(any)
    tags                           = optional(map(string), {})
  }))
  default = {}
}

variable "cloudfront_distributions" {
  description = "Map of CloudFront distribution configurations"
  type = map(object({
    aliases                 = optional(list(string), [])
    origin                  = optional(any)
    origin_group            = optional(any)
    origin_access_control   = optional(any)
    default_cache_behavior  = optional(any)
    ordered_cache_behavior  = optional(any)
    custom_error_response   = optional(any)
    restrictions            = optional(any)
    viewer_certificate      = optional(any)
    response_headers_policy = optional(any)
    custom_headers          = optional(any)
    logging_config          = optional(any)
    log_delivery            = optional(any)
    vpc_origin              = optional(any)
    default_root_object     = optional(string, "index.html")
    tags                    = optional(map(string), {})
  }))
  default = {}
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  type        = string
  default     = "three-tier-frontend-bucket-aaditya-2901"
}

variable "s3_force_destroy" {
  description = "Allow destroying bucket even with objects"
  type        = bool
  default     = true
}

variable "s3_versioning" {
  description = "Enable versioning on the S3 bucket"
  type = object({
    status = string
  })
  default = {
    status = "Enabled"
  }
}

variable "s3_cors_rule" {
  description = "CORS rule for the S3 bucket"
  type = list(object({
    allowed_headers = optional(list(string), [])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3000)
  }))
  default = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
      expose_headers  = ["ETag"]
    }
  ]
}

variable "s3_bucket_policy" {
  description = "Bucket policy JSON for the frontend S3 bucket"
  type        = string
  default     = null
}

variable "s3_public_access_block" {
  description = "Public access block configuration for frontend S3 bucket"
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  default = {}
}

variable "s3_ownership_controls" {
  description = "Object ownership for S3 bucket"
  type = object({
    object_ownership = string
  })
  default = null
}

variable "s3_acl" {
  description = "Canned ACL for the S3 bucket"
  type        = string
  default     = null
}

variable "s3_server_side_encryption" {
  description = "SSE configuration for the S3 bucket"
  type = object({
    sse_algorithm     = string
    kms_master_key_id = optional(string)
  })
  default = {
    sse_algorithm = "AES256"
  }
}

variable "cf_origin_secret" {
  description = "Secret header injected by CloudFront for ALB protection"
  type        = string
  default     = "super-secret-value"
}

variable "backend_image_tag" {
  description = "The tag of the backend image to deploy"
  type        = string
  default     = "latest"
}
