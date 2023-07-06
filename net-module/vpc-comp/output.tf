
output "network-resource-share-arn" {
  value = aws_ram_resource_share.AMI-Network-us-east-1-TGW-Shares.arn
}


output "net-sg-id" {
  value = aws_security_group.Net-sg[*].id
}


