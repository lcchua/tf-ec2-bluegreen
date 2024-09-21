data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "Allow public traffic to alb"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description      = "TLS from outside world"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name}-app"
  description = "Allow alb traffic to app"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_lb" "app" {
  name               = "${var.name}-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.public.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
    # forward {
    #   target_group {
    #     arn =     aws_lb_target_group.blue.arn
    #     weight = lookup(local.traffic_dist_map[var.traffic_distribution], "blue", 100)
    #   }

    #   target_group {
    #     arn =    aws_lb_target_group.green.arn
    #     weight = lookup(local.traffic_dist_map[var.traffic_distribution], "green", 0)
    #   }

    #   stickiness {
    #     enabled  = false
    #     duration = 1
    #   }
    # }
  }
}
