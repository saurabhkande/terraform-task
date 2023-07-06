variable "region" {
   default = "us-east-1"
}

variable "net-cred" {                     
     type = map
	 default = {
	 
	 "access_key" = "AKIA6FIZKHHDMQJMKBCG" 
	 "secret_key" = "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"
    }
}

variable "vpc-cidr" {
   type = string
   default = "10.96.0.0/21"
}

variable "vpc-tag" {
   type = string
   default = "AMI-Network-vpc"
}
variable "az" {
   type = list
   default =["us-east-1a","us-east-1b","us-east-1c","us-east-1a","us-east-1b","us-east-1c"]
}

variable "private_subnet_tag" {
   type = list
   default =["ami-network-tgw-subnet-1","ami-network-tgw-subnet-2","ami-network-trust-subnet-1","ami-network-trust-subnet-2","ami-network-app-subnet-1","ami-network-app-subnet-2"]
}

variable "public_subnet_tag" {
   type = list
   default =["ami-network-lb-subnet-1","ami-network-lb-subnet-2","ami-network-untrust-subnet-1","ami-network-untrust-subnet-2","ami-network-management-subnet-1","ami-network-management-subnet-2"]
}

variable "private_subnet_cidr_range" {
   type = list
   default =["10.96.7.0/27","10.96.7.32/27","10.96.2.0/27","10.96.2.32/27","10.96.6.0/25","10.96.6.128/25"]
}

variable "public_subnet_cidr_range" {
   type = list
   default =["10.96.4.0/24","10.96.5.0/24","10.96.0.0/24","10.96.1.0/24","10.96.3.0/28","10.96.3.16/28"]
}

variable "nacl" {
   type = list
   default =["AMI-Network-Private-NACL","AMI-Network-Public-NACL"]
}

variable "ngw" {
   type = list
   default =["AMI-Network-us-east-1-NAT-1","AMI-Network-us-east-1-NAT-2"]
}

variable "eip" {
   type = list
   default =["AMI-Network-us-east-1-EIP-1","AMI-Network-us-east-1-EIP-2"]
}

variable "route-table" {
   type = list
   default =["AMI-Network-Private-RT-1","AMI-Network-Private-RT-2","AMI-Network-Public-RT"]
}

variable "TGW-routes-cidr" {
   type = list
   default =["172.16.0.0/18","172.16.76.0/24","172.16.77.0/24","172.16.96.0/21","172.16.80.0/23"]
}

variable "TGW-routes-name" {
   type = list
   default =["ami-network-us-east-1-vpn-taiwan-TGWA","ami-network-us-east-1-vpn-usoffice-TGWA","ami-network-us-east-1-vpn-usoffice-TGWA","ami-network-us-east-1-vpn-usoffice-TGWA","ami-network-us-east-1-vpn-china-TGWA"]
}
