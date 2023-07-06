
# VPC
resource "aws_vpc" "ami-dev-us-east-1-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "ami-dev-us-east-1-vpc"
  }
}

# Security Group

resource "aws_security_group" "dev-sg" {
  name        = "dev-sg"
  description = "dev-sg-for-ecs-farget"
  vpc_id      = aws_vpc.ami-dev-us-east-1-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.ami-dev-us-east-1-vpc.cidr_block]  
  }
  
  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]     
  }
  
  ingress {
    description      = "TLS from VPC"
    from_port        = 90
    to_port          = 90
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]     
  }

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.ami-dev-us-east-1-vpc.cidr_block]    
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-for-ecs-farget"
  }
}

resource "aws_subnet" "public-subnets" {
  vpc_id     = aws_vpc.ami-dev-us-east-1-vpc.id
  cidr_block = var.public_subnet_cidr_range[count.index]
  availability_zone = var.az[count.index]
  map_public_ip_on_launch = true
  count = 2
  tags = {
    Name = var.public_subnet_tag[count.index]
  }
}

# IGW
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.ami-dev-us-east-1-vpc.id

  tags = {
    Name = var.igw
  }
}
resource "aws_eip" "EIP" {
  domain = "vpc"
  tags = {
    Name = var.eip
  }
}

# SUBNETS

resource "aws_subnet" "private-subnets" {
  vpc_id     = aws_vpc.ami-dev-us-east-1-vpc.id
  cidr_block = var.private_subnet_cidr_range[count.index]
  availability_zone = var.az[count.index]
  count = 6
  tags = {
    Name = var.private_subnet_tag[count.index]
  }
}


# Route table

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.ami-dev-us-east-1-vpc.id
  count  = 2
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = var.route-table[count.index]
  }
}

resource "aws_route_table_association" "pri-rt-association" {
  subnet_id      = element(aws_subnet.private-subnets.*.id, 1)
  route_table_id = element(aws_route_table.RT.*.id, 0)

}

resource "aws_route_table_association" "pub-rt-association" {
  subnet_id      = element(aws_subnet.public-subnets.*.id, 1)
  route_table_id = element(aws_route_table.RT.*.id, 1)

}


# Nat-gateway

resource "aws_nat_gateway" "NAT-GW" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = element(aws_subnet.public-subnets.*.id, 0)

  tags = {
    Name = var.ngw
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

/*
# S3 bucket

resource "aws_s3_bucket" "public_bucket_flowlog" {
  bucket = "ssk56951"
}

resource "aws_s3_bucket_ownership_controls" "s3-ownership" {
  bucket = aws_s3_bucket.public_bucket_flowlog.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-access" {
  bucket = aws_s3_bucket.public_bucket_flowlog.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "s3-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3-ownership,
    aws_s3_bucket_public_access_block.s3-access,
  ]

  bucket = aws_s3_bucket.public_bucket_flowlog.id
  acl    = "public-read"
}


resource "aws_s3_bucket_versioning" "s3-versioning" {
  bucket = aws_s3_bucket.public_bucket_flowlog.id
  versioning_configuration {
    status = "Disabled"
  }
}

# VPC flow log

resource "aws_flow_log" "vpc-flow-log" {
  traffic_type = "ALL"
  log_destination_type = "s3"
  log_destination = aws_s3_bucket.public_bucket_flowlog.arn
  vpc_id = aws_vpc.ami-dev-us-east-1-vpc.id

  tags = {
    Name = "vpc-flow-log"
  }
}
*/

# NACL private

resource "aws_network_acl" "AMI-dev-Private-NACL" {
  vpc_id = aws_vpc.ami-dev-us-east-1-vpc.id

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  egress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "Dev-private-nacl"
  }
}

# NACL public

resource "aws_network_acl" "AMI-dev-Public-NACL" {
  vpc_id = aws_vpc.ami-dev-us-east-1-vpc.id

  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
  egress {
    rule_no    = 200
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }
  tags = {
    Name = "Dev-public-nacl"
  }
}



resource "aws_ram_resource_share" "dev_resource_share" {
  name        = "Development Resource Share"
  allow_external_principals = true
}

resource "aws_ram_principal_association" "net-principle" {
  principal          = "973400062406"
  resource_share_arn = aws_ram_resource_share.dev_resource_share.arn
}



resource "aws_ec2_transit_gateway" "transit_gateway" {
   description                    = "cross account resource sharing"
   auto_accept_shared_attachments = "enable"
   tags = {
      Name = "AMI-Network-us-east-1-TGW"  
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "ami-devnet-us-east-1-vpc-TGWA" {
  transit_gateway_id       = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id                   = aws_vpc.ami-dev-us-east-1-vpc.id
  subnet_ids               = toset(slice(aws_subnet.public-subnets.*.id, 0,1))
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}

