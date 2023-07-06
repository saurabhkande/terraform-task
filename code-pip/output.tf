/*
output "s3_arn" {
    value = aws_s3_bucket.public_bucket.arn
}
*/

output "load_balancer_ip" {
  value = aws_lb.BG-task-ALB.dns_name
}


