terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}
provider "aws" {
  alias   = "net-account"
  region  = us-east-1
  profile = "973400062406"
}

