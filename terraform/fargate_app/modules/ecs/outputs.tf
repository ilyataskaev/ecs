output "log_group_name" {
  value = aws_cloudwatch_log_group.log_group.name
}
output "lb_dns_name" {
  value = aws_lb.public_lb[0].dns_name
}