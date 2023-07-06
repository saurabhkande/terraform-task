# VPC
resource "aws_vpc" "AMI-Network-vpc" {
  cidr_block = var.vpc-cidr
  
  tags = {
    Name = var.vpc-tag
  }
}

# Security Group

resource "aws_security_group" "Net-sg" {
  name        = "net-sg"
  description = "net-sg-for-lb"
  vpc_id      = aws_vpc.AMI-Network-vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.AMI-Network-vpc.cidr_block]  
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
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.AMI-Network-vpc.cidr_block]    
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG-for-alb"
  }
}


resource "aws_subnet" "public-subnets" {
  vpc_id     = aws_vpc.AMI-Network-vpc.id
  cidr_block = var.public_subnet_cidr_range[count.index]
  availability_zone = var.az[count.index]
  map_public_ip_on_launch = true
  count = 6
  tags = {
    Name = var.public_subnet_tag[count.index]
  }
}
# IGW

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.AMI-Network-vpc.id

  tags = {
    Name = "AMI-Network-us-east-1-IGW"
  }
}

resource "aws_lb" "Net-ALB" {
  name               = "Net-waf-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public-subnets[0].id,aws_subnet.public-subnets[1].id]
  security_groups    = aws_security_group.Net-sg[*].id
}

resource "aws_lb_target_group" "Net-ALB-tg" {
  name        = "Net-waf-ALB-tg"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.AMI-Network-vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "Net-ALB-listener" {
  load_balancer_arn = aws_lb.Net-ALB.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.Net-ALB-tg.id
    type             = "forward"
  }
}


# EIP
resource "aws_eip" "EIP" {
  domain = "vpc"
  count = 2
  tags = {
    Name = var.eip[count.index]
  }
}


# SUBNETS
resource "aws_subnet" "private-subnets" {
  vpc_id     = aws_vpc.AMI-Network-vpc.id
  cidr_block = var.private_subnet_cidr_range[count.index]
  availability_zone = var.az[0]
  count = 6
  tags = {
    Name = var.private_subnet_tag[count.index]
  }
}


# Route table

resource "aws_route_table" "RT" {                              
  vpc_id = aws_vpc.AMI-Network-vpc.id
  count  = 3
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.NAT-GW.*.id, count.index)
  }
  
  tags = {
    Name = var.route-table[count.index]
  }					
}

resource "aws_route_table_association" "private-RT" {
  subnet_id      = element(aws_subnet.private-subnets.*.id, 1)                           # 
  route_table_id = element(aws_route_table.RT.*.id, 0)             
  
}

resource "aws_route_table_association" "private-RT-2" {
  subnet_id      = element(aws_subnet.private-subnets.*.id, 2)                           
  route_table_id = element(aws_route_table.RT.*.id, 1)
  
}

resource "aws_route_table_association" "public-RT" {
  subnet_id      = element(aws_subnet.public-subnets.*.id, 1)                           
  route_table_id = element(aws_route_table.RT.*.id, 2)

}



# Nat-gateway

resource "aws_nat_gateway" "NAT-GW" {
  allocation_id = element(aws_eip.EIP.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnets.*.id, count.index)
  count = 2

  tags = {
    Name = var.ngw[count.index]
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IGW]
}

# NACL public

resource "aws_network_acl" "AMI-Network-Public-NACL" {
  vpc_id = aws_vpc.AMI-Network-vpc.id

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
    Name = "public-nacl"
  }
}

# NACL private

resource "aws_network_acl" "AMI-Network-Private-NACL" {
  vpc_id = aws_vpc.AMI-Network-vpc.id

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
    Name = "private-nacl"
  }
}

# S3 bucket

resource "aws_s3_bucket" "public_bucket" {
  bucket = "sskflowlog"
}

resource "aws_s3_bucket_ownership_controls" "s3-ownership" {
  bucket = aws_s3_bucket.public_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3-access" {
  bucket = aws_s3_bucket.public_bucket.id

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

  bucket = aws_s3_bucket.public_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "s3-versioning" {
  bucket = aws_s3_bucket.public_bucket.id
  versioning_configuration {
    status = "Disabled"
  }  
}

# VPC flow log

resource "aws_flow_log" "net-vpc-flow-log" {
  traffic_type = "ALL"
  log_destination_type = "s3"
  log_destination = aws_s3_bucket.public_bucket.arn
  vpc_id = aws_vpc.AMI-Network-vpc.id

  tags = {
    Name = "vpc-flow-log"
  }
}

resource "aws_wafregional_ipset" "ipset" {
  name = "tfIPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = "192.0.7.0/24"
  }
}

resource "aws_wafregional_rule" "waf-rule" {
  name        = "tfWAFRule"
  metric_name = "tfWAFRule"

  predicate {
    data_id = aws_wafregional_ipset.ipset.id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "net-web-acl" {
  name        = "external"
  metric_name = "external"

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "BLOCK"
    }

    priority = 1
    rule_id  = aws_wafregional_rule.waf-rule.id
  }
}

resource "aws_wafregional_web_acl_association" "acl-association" {
  resource_arn = aws_lb.Net-ALB.arn
  web_acl_id   = aws_wafregional_web_acl.net-web-acl.id
}



# Transit-gateway

resource "aws_ec2_transit_gateway" "TGW" {
  description = "cross account resurce sharing"
  auto_accept_shared_attachments = "enable"

  tags = {
    Name = "AMI-Network-us-east-1-TGW"

  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "ami-devnet-us-east-1-vpc-TGWA" {
  transit_gateway_id       = aws_ec2_transit_gateway.TGW.id
  vpc_id                   = aws_vpc.AMI-Network-vpc.id
  subnet_ids               = toset(slice(aws_subnet.public-subnets.*.id, 2,3))
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
}

resource "aws_ec2_transit_gateway_route_table" "ami-network-us-east-1-tgw-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  tags = {
    Name = "ami-network-us-east-1-tgw-rt"
  }
}

resource "aws_ec2_transit_gateway_route" "TGW-routes" {
  transit_gateway_route_table_id         = aws_ec2_transit_gateway_route_table.ami-network-us-east-1-tgw-rt.id
  destination_cidr_block                 = var.TGW-routes-cidr[count.index]
  transit_gateway_attachment_id          = aws_ec2_transit_gateway_vpc_attachment.ami-devnet-us-east-1-vpc-TGWA.id
  count = 5
}

# RAM

resource "aws_ram_resource_share" "AMI-Network-us-east-1-TGW-Shares" {
  name                      = "AMI-Network-us-east-1-TGW-Shares"
  allow_external_principals = true
  tags = {
    Environment = "NETWORK-ACC"
  }
}

resource "aws_ram_resource_association" "net_to_dev_association" {
    resource_share_arn = aws_ram_resource_share.AMI-Network-us-east-1-TGW-Shares.arn
    resource_arn       = aws_ec2_transit_gateway.TGW.arn
}


resource "aws_ram_principal_association" "network_to_dev_association" {
   resource_share_arn = aws_ram_resource_share.AMI-Network-us-east-1-TGW-Shares.arn 
   principal          = "009609560581"
}



