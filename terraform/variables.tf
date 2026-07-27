variable "aws_region" {
  description = "AWS region used for the migration simulation."
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "simulation"
}
