
output "vpc_id" {
  value = aws_vpc.ami-dev-us-east-1-vpc.id
}

output "sg_id" {
  value = aws_security_group.dev-sg[*].id
}


output "subnet-id" {
  value = aws_subnet.public-subnets[*].id
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.transit_gateway.id
}

output "dev-res-share-arn" {
  value = aws_ram_resource_share.dev_resource_share.arn
}

