terraform {
  required_version = "~> 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Name      = "foo"
      Terraform = "true"
    }
  }
}

resource "random_string" "random" {
  length  = 4
  special = false
}
