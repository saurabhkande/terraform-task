
module "network" {
source = "./net-module/vpc-comp"
providers = {
    aws = aws.net-account
  }
}

module "develop" {
source = "./dev-module/vpc-comp"
providers = {
    aws = aws.dev-account
  }
}

module "code-pip" {
source = "./code-pip"
providers = {
    aws = aws.dev-account
  }
}

# Backend s3
terraform {
  backend "s3" {
    bucket = "ssk12345"
    key    = "tfstate/net-module"
    region = "us-east-1"
  }
}


