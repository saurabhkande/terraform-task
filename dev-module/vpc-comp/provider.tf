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
  region  = us-east-1
  profile = "009609560581"
}
