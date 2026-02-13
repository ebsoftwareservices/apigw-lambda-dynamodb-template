terraform {
  required_version = "~> 1.14.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.32.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Name      = "bedrock"
      Terraform = "true"
    }
  }
}

resource "random_string" "random" {
  length  = 4
  special = false
}
