output "global_cluster_id" {
  description = "ID of the Aurora Global Cluster"
  value       = aws_rds_global_cluster.this.id
}

output "primary_cluster_endpoint" {
  description = "Writer endpoint for Aurora (auto-switch on failover)"
  value       = module.aurora_primary.cluster_endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint for read scaling"
  value       = module.aurora_primary.cluster_reader_endpoint
}

output "secondary_cluster_endpoint" {
  description = "Secondary cluster endpoint (read-only until promotion)"
  value       = module.aurora_secondary.cluster_endpoint
}

output "master_user_secret_arn" {
  description = "The ARN of the master user secret created in Secrets Manager"
  value       = aws_secretsmanager_secret.db_password.arn
}
