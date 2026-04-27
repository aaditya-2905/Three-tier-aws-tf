# ═══════════════════════════════════════════════════════════════
# Outputs — Three-Tier Application
# ═══════════════════════════════════════════════════════════════

# ─── VPC ──────────────────────────────────────────────────────
output "vpc_ids" {
  description = "IDs of created VPCs"
  value       = module.vpc.vpc_ids
}

output "primary_public_subnet_ids" {
  description = "Public subnet IDs in primary region"
  value       = data.aws_subnets.primary_public.ids
}

output "primary_private_subnet_ids" {
  description = "Private subnet IDs in primary region"
  value       = data.aws_subnets.primary_private.ids
}

output "secondary_public_subnet_ids" {
  description = "Public subnet IDs in secondary region"
  value       = data.aws_subnets.secondary_public.ids
}

output "secondary_private_subnet_ids" {
  description = "Private subnet IDs in secondary region"
  value       = data.aws_subnets.secondary_private.ids
}

# ─── Security Groups ─────────────────────────────────────────
output "sg_ids" {
  description = "IDs of created security groups"
  value       = module.sg.sg_ids
}

# ─── ALB ──────────────────────────────────────────────────────
output "primary_alb_dns" {
  description = "DNS name of the primary ALB"
  value       = module.alb_primary.alb_dns_name
}

output "primary_alb_arn" {
  description = "ARN of the primary ALB"
  value       = module.alb_primary.alb_arn
}

output "primary_alb_target_group_arns" {
  description = "Target group ARNs of the primary ALB"
  value       = module.alb_primary.target_group_arns
}

output "secondary_alb_dns" {
  description = "DNS name of the secondary ALB"
  value       = module.alb_secondary.alb_dns_name
}

output "secondary_alb_arn" {
  description = "ARN of the secondary ALB"
  value       = module.alb_secondary.alb_arn
}

output "secondary_alb_target_group_arns" {
  description = "Target group ARNs of the secondary ALB"
  value       = module.alb_secondary.target_group_arns
}

# ─── IAM ──────────────────────────────────────────────────────
output "iam_role_arns" {
  description = "ARNs of created IAM roles"
  value       = module.iam.role_arns
}

# ─── ECR ──────────────────────────────────────────────────────
output "ecr_repository_urls" {
  description = "Repository URLs of created ECR repositories"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ARNs of created ECR repositories"
  value       = module.ecr.repository_arns
}

# ─── ECS ──────────────────────────────────────────────────────
output "ecs_cluster_arns" {
  description = "ARNs of created ECS clusters"
  value       = module.ecs.cluster_arns
}

output "ecs_service_arns" {
  description = "ARNs of created ECS services"
  value       = module.ecs.service_arns
}

# ─── CloudFront ───────────────────────────────────────────────
output "cloudfront_distribution_ids" {
  description = "IDs of created CloudFront distributions"
  value       = module.cloudfront.distribution_ids
}

output "cloudfront_domain_names" {
  description = "Domain names of created CloudFront distributions"
  value       = module.cloudfront.distribution_domain_names
}

# ─── S3 ───────────────────────────────────────────────────────
output "s3_frontend_bucket_id" {
  description = "Name of the frontend S3 bucket"
  value       = module.s3_frontend.bucket_id
}

output "s3_frontend_bucket_arn" {
  description = "ARN of the frontend S3 bucket"
  value       = module.s3_frontend.bucket_arn
}



# ─── RDS Global ──────────────────────────────────────────────
output "rds_global_cluster_id" {
  description = "ID of the Aurora Global Cluster"
  value       = module.rds_global.global_cluster_id
}

output "rds_primary_endpoint" {
  description = "Writer endpoint for Aurora primary"
  value       = module.rds_global.primary_cluster_endpoint
}

output "rds_reader_endpoint" {
  description = "Reader endpoint for Aurora"
  value       = module.rds_global.reader_endpoint
}

output "rds_secondary_endpoint" {
  description = "Secondary cluster endpoint (read-only until promotion)"
  value       = module.rds_global.secondary_cluster_endpoint
}

output "rds_master_secret_arn" {
  description = "ARN of the master user secret in Secrets Manager"
  value       = module.rds_global.master_user_secret_arn
}
