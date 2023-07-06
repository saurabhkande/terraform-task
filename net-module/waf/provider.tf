terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}
provider "aws" {
  region = us-east-1
  alias = "net-account"
  profile = "973400062406"
}

