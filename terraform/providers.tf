provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "vcp-to-aws-migration-simulation"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
