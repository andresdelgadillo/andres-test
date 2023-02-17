
output "ec2_sg" {
  value       = aws_security_group.sg_ec2
  description = "AWS EC2 SG"
}
