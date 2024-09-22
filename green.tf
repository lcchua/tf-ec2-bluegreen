data "aws_ami" "green" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "green" {
  count = var.enable_green_env ? 2 : 0

  ami                    = data.aws_ami.green.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.private.ids[count.index % length(data.aws_subnets.private.ids)]
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data = templatefile("${path.module}/init-script.sh", {
    file_content = "green v1.0 - #${count.index}"
  })

  tags = {
    Name = "${var.name}-green-${count.index}"
  }
}

resource "aws_lb_target_group" "green" {
  name     = "${var.name}-green-tg-lb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 3
    interval = 5
  }
}

resource "aws_lb_target_group_attachment" "green" {
  count            = length(aws_instance.green)
  target_group_arn = aws_lb_target_group.green.arn
  target_id        = aws_instance.green[count.index].id
  port             = 80
}
