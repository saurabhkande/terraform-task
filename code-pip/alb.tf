
resource "aws_lb" "BG-task-ALB" {
  name               = var.lb-name
  internal           = false
  load_balancer_type = var.lb-type
  subnets         = module.develop.subnet-id
  security_groups = module.develop.sg_id
}

resource "aws_lb_target_group" "BG-task-ALB-tg" {
  name        = var.tg-name
  port        = var.lb-port
  protocol    = var.lb-protocol
  vpc_id      = module.develop.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "BG-listener" {
  load_balancer_arn = aws_lb.BG-task-ALB.id
  port              = var.lb-port
  protocol          = var.lb-protocol

  default_action {
    target_group_arn = aws_lb_target_group.BG-task-ALB-tg.id
    type             = "forward"
  }  
}

resource "aws_lb_listener_rule" "static-1" {
  listener_arn = aws_lb_listener.BG-listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.BG-task-ALB-tg.arn
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }

  condition {
    host_header {
      values = ["Net-waf-alb-1444801768.us-east-1.elb.amazonaws.com"]
    }
  }
}



# Green

resource "aws_lb_target_group" "Green-task-ALB-tg" {
  name        = "Blue-tg"
  port        = "90"
  protocol    = "HTTP"
  vpc_id      = module.develop.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "Green-listener" {
  load_balancer_arn = aws_lb.BG-task-ALB.id
  port              = "90"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.Green-task-ALB-tg.id
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.Green-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Green-task-ALB-tg.arn
  }

  condition {
    path_pattern {
      values = ["/static/*"]
    }
  }

  condition {
    host_header {
      values = ["Net-waf-alb-1444801768.us-east-1.elb.amazonaws.com"]
    }
  }
}

