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
  name        = "net-web-acl"
  metric_name = "net-web-acl-metric"

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
  resource_arn = aws_alb.Net-ALB.arn
  web_acl_id   = aws_wafregional_web_acl.net-web-acl.id
}