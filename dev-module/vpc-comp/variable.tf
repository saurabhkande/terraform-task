variable "region" {
   default = "us-east-1"
}

variable "credentials" {                     
     type = map
	 default = {
	 
	 "access_key" = "AKIA6FIZKHHDMQJMKBCG" 
	 "secret_key" = "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"
    }
}

variable "vpc_cidr" {
   default = "10.100.0.0/21"
}
variable "az" {
   type = list
   default =["us-east-1a","us-east-1b","us-east-1a","us-east-1b","us-east-1a","us-east-1b"]
}

variable "private_subnet_tag" {
   type = list
   default =["ami-dev-subnet-web-private1-us-east-1a","ami-dev-subnet-web-private2-us-east-1b","ami-dev-subnet-app-private1-us-east-1a","ami-dev-subnet-app-private2-us-east-1b","ami-dev-subnet-db-private1-us-east-1a","ami-dev-subnet-db-private2-us-east-1b"]
}

variable "public_subnet_tag" {
   type = list
   default =["ami-dev-subnet-lb-public1-us-east-1a","ami-dev-subnet-lb-public2-us-east-1b"]
}

variable "private_subnet_cidr_range" {
   type = list
   default =["10.100.2.0/24","10.100.3.0/24","10.100.4.0/24","10.100.7.0/24","10.100.5.0/24","10.100.6.0/24"]
}

variable "public_subnet_cidr_range" {
   type = list
   default =["10.100.0.0/24","10.100.1.0/24"]
}

variable "nacl" {
   type = list
   default =["AMI-dev-Private-NACL","AMI-dev-Public-NACL"]
}

variable "ngw" {
   type = string
   default = "AMI-dev-us-east-1-NAT"
}

variable "eip" {
   type = string
   default = "AMI-dev-us-east-1-EIP"
}

variable "route-table" {
   type = list
   default =["AMI-dev-Private-RT","AMI-dev-Public-RT"]
}

variable "routes-local-cidr-ranges" {
   type = list
   default =["10.100.0.0/21","10.96.0.0/21"]
}
variable "igw" {
   type = string
   default = "AMI-dev-us-east-1-IGW"
}





