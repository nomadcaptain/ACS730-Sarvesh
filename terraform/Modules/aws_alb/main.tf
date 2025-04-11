# create security group for the application load balancer
resource "aws_security_group" "alb_security_group" {
  name        = "${var.prefix}-alb-sg"
  description = "Security group for ALB to enable HTTP access"
  vpc_id      = var.vpc_id
  ingress {
    description      = "HTTP access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  # -1 signifies all protocols
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = { 
    Name = "${var.prefix}-alb-sg"
  }
}

# create application load balancer
resource "aws_lb" "application_load_balancer" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = var.subnet_ids
  enable_deletion_protection = false
  tags   = {
    Name = "${var.prefix}-alb"
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "${var.prefix}-tg"
  # target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }
  lifecycle {
    create_before_destroy = true
  }
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# Create target group attachment for each web server
resource "aws_lb_target_group_attachment" "web_server_attachments" {
  count = length(var.webserver_ids)
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = var.webserver_ids[count.index]
  port             = 80
}