terraform {
  backend "s3" {
    bucket         = "three-tier-app-tf-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "three-tier-app-terraform-locks"
    encrypt        = true
  }
}
