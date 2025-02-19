
# Setting up a Terraform configuration that sets up a fully automated ALB with
# Auto Scaling deployment with Blue-Green Deployment support
# - Application Load Balancer (ALB) - Routes HTTP traffic
# - Target Groups (Blue & Green) - For Blue-Green deployment
# - Auto Scaling Group (ASG) & Launch Template - Dynamically scales EC2 instances
# - Dynamic Traffic Switching - Using ALB Listener with weighted target groups0
# - Health Checks - Ensures only healthy instances receive traffic
# - Custom User Data - Bootstraps instances with a script

variable "vpc_id" {}  
variable "subnet_ids" {}  
variable "instance_type" { default = "t3.micro" }  
variable "ami_id" {}  
variable "name" { default = "app" }  
variable "traffic_distribution" { default = "all_blue" }  

locals {  
  traffic_dist_map = {  
    "all_blue"   = { blue = 100, green = 0 }  
    "all_green"  = { blue = 0, green = 100 }  
    "gradual"    = { blue = 80, green = 20 }  
  }  
}  

resource "aws_lb" "app" {  
  name               = "${var.name}-alb"  
  internal           = false  
  load_balancer_type = "application"  
  security_groups    = [aws_security_group.alb_sg.id]  
  subnets            = var.subnet_ids  
}  

resource "aws_lb_target_group" "blue" {
  name     = "${var.name}-blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path     = "/health"
    interval = 10
    timeout  = 5
  }
}

resource "aws_lb_target_group" "green" {
  name     = "${var.name}-green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = lookup(local.traffic_dist_map[var.traffic_distribution], "blue", 100)
      }
      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = lookup(local.traffic_dist_map[var.traffic_distribution], "green", 0)
      }
    }
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.name}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/init-script.sh", {
    file_content = "blue v1.0"
  }))
}

resource "aws_autoscaling_group" "blue" {
  name                = "${var.name}-blue-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 4
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.blue.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "green" {
  name                = "${var.name}-green-asg"
  desired_capacity    = 2
  min_size            = 1
  max_size            = 4
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.green.arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}
