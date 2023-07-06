resource "aws_lb" "Net-ALB" {
  name               = "Net-waf-alb"
  internal           = false
  load_balancer_type = "Application"
  subnets            = aws_subnet.public-subnets[*].id
  security_groups    = aws_security_group.Net-sg.id
}

resource "aws_lb_target_group" "Net-ALB-tg" {
  name        = Net-waf-ALB-tg
  port        = "80"
  protocol    = "http"
  vpc_id      = aws_vpc.AMI-Network-vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "Net-ALB-listener" {
  load_balancer_arn = aws_lb.Net-ALB.id
  port              = "80"
  protocol          = "http"
  default_action {
    target_group_arn = aws_lb_target_group.Net-ALB-tg.id
    type             = "forward"
  }
}