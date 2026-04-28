resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = "global-db"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.0"
  storage_encrypted         = true
}

resource "aws_kms_key" "primary" {
  description             = "KMS key for primary aurora"
  deletion_window_in_days = 7
}

module "aurora_primary" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = "three-tier-aurora-primary-v2"
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.04.0"

  cluster_instance_class = "db.r5.large"
  instances              = { one = {} }

  vpc_id                 = var.primary_vpc_id
  subnets                = var.primary_subnets
  create_db_subnet_group = true

  security_group_ingress_rules = {
    ingress_ecs = {
      from_port                    = 3306
      to_port                      = 3306
      ip_protocol                  = "tcp"
      referenced_security_group_id = var.primary_sg_id
    }
  }

  storage_encrypted           = true
  kms_key_id                  = aws_kms_key.primary.arn
  global_cluster_identifier   = aws_rds_global_cluster.this.id
  master_username             = "admin"
  database_name               = "school"
  master_password_wo          = random_password.master.result
  master_password_wo_version  = 1
  manage_master_user_password = false
  backup_retention_period     = 7
  skip_final_snapshot         = true
}

resource "random_password" "master" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_password" {
  name_prefix             = "aurora-db-password-"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.master.result
  })
}

resource "aws_kms_key" "secondary" {
  provider                = aws.secondary
  description             = "KMS key for secondary aurora"
  deletion_window_in_days = 7
}

module "aurora_secondary" {
  source = "terraform-aws-modules/rds-aurora/aws"

  providers = { aws = aws.secondary }

  name           = "three-tier-aurora-secondary-v2"
  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.04.0"

  cluster_instance_class = "db.r5.large"
  instances              = { one = {} }

  vpc_id                 = var.secondary_vpc_id
  subnets                = var.secondary_subnets
  create_db_subnet_group = true

  security_group_ingress_rules = {
    ingress_ecs = {
      from_port                    = 3306
      to_port                      = 3306
      ip_protocol                  = "tcp"
      referenced_security_group_id = var.secondary_sg_id
    }
  }

  storage_encrypted         = true
  kms_key_id                = aws_kms_key.secondary.arn
  global_cluster_identifier = aws_rds_global_cluster.this.id
  skip_final_snapshot       = true
  source_region             = "us-east-1"

  depends_on = [module.aurora_primary]
}
