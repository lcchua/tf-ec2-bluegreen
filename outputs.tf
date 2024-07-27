
output "lb_dns_name" {
  value = "http://${aws_lb.app.dns_name}"
}
