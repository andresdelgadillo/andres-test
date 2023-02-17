
output "aws_alb" {
  value       = aws_lb.alb
  description = "AWS ALB"
}

output "alb_sg" {
  value       = aws_security_group.sg_alb
  description = "AWS ALB SG"
}

output "alb_tg" {
  value       = aws_lb_target_group.alb_target_group
  description = "AWS ALB TG"
}
