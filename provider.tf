terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.15.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile                 = "default"
  region = var.aws_region
}
