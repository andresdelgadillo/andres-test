terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


data "aws_caller_identity" "current" {

}

data "aws_region" "current" {
  provider = aws
}

data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-x86_64-gp2"]
  }
}


resource "aws_security_group_rule" "allow_http_inbound" {
  description              = "${var.app_name}-ingress"
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.security_group_alb.id
  security_group_id        = aws_security_group.sg_ec2.id
}

resource "aws_security_group_rule" "allow_ssm_egress" {
  description       = "${var.app_name}-ssm-egress"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ec2.id
}

resource "aws_security_group_rule" "allow_rds_egress" {
  description       = "${var.app_name}-rds-egress"
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = ["10.0.2.0/23"]
  security_group_id = aws_security_group.sg_ec2.id
}

resource "aws_security_group" "sg_ec2" {
  name        = "${var.app_name}-ec2_${var.environment}"
  description = "EC2 ${var.app_name} security group"
  vpc_id      = var.vpc.id

  tags = {
    Name = "${var.app_name}-ec2_${var.environment}"
  }
}

resource "aws_launch_template" "ec2_launch_template" {
  name                   = var.app_name
  image_id               = data.aws_ami.latest.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = ["${aws_security_group.sg_ec2.id}"]
  user_data              = filebase64("${path.module}/user-data.sh")

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-instance-profile.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.app_name}"
      environment = "${var.environment}"
    }
  }

}

resource "aws_autoscaling_group" "ec2_launch_autoscaling" {
  name                      = var.app_name
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.private_subnets
  target_group_arns         = ["${var.target_group.arn}"]
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.app_name}-cpu-scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.ec2_launch_autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description   = "Monitors decrease CPU utilization for ${var.app_name} ASG"
  alarm_actions       = ["${aws_autoscaling_policy.scale_down.arn}"]
  alarm_name          = "${var.app_name}_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "40"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.ec2_launch_autoscaling.name}"
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.app_name}-cpu-scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.ec2_launch_autoscaling.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_description   = "Monitors increase CPU utilization for ${var.app_name} ASG"
  alarm_actions       = ["${aws_autoscaling_policy.scale_up.arn}"]
  alarm_name          = "${var.app_name}_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "65"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.ec2_launch_autoscaling.name}"
  }
}
