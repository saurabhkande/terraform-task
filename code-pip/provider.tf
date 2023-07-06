terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

provider "aws" {
  alias   = "dev-account"
  region  = var.region
  profile = "009609560581"
  access_key = var.net-cred["access_key"]
  secret_key = var.net-cred["secret_key"]

  assume_role {
    role_arn = "arn:aws:iam::009609560581:role/terra-role"
  }
}

