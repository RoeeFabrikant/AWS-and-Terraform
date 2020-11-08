resource "aws_elb" "opsschool_elb" {
    name              = "opsschool-elb"
    security_groups   = [aws_security_group.elb_sg.id]
    subnets           = aws_subnet.public_sub.*.id
    instances         = var.web_servers_id

    listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }

    health_check {
      target              = "HTTP:80/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5 
    }
}

resource "aws_lb_cookie_stickiness_policy" "elb_stickness_policy" {
  name = "${var.project_name}-stickness-policy"
  load_balancer = aws_elb.opsschool_elb.id
  lb_port = 80
  cookie_expiration_period = 60
}