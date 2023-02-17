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


resource "aws_security_group_rule" "allow_ec2_inbound" {
  description = "${var.app_name}-ec2-ingress"
  type        = "ingress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  # cidr_blocks              = ["10.0.0.0/23"]
  source_security_group_id = var.security_group_ec2.id
  security_group_id        = aws_security_group.sg_rds.id
}

resource "aws_security_group_rule" "allow_ec2_egress" {
  description = "${var.app_name}-ec2-egress"
  type        = "egress"
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  # cidr_blocks              = ["10.0.0.0/23"]
  source_security_group_id = var.security_group_ec2.id
  security_group_id        = aws_security_group.sg_rds.id
}

resource "aws_security_group" "sg_rds" {
  name        = "${var.app_name}-rds_${var.environment}"
  description = "RDS ${var.app_name} security group"
  vpc_id      = var.vpc.id

  tags = {
    Name = "${var.app_name}-rds_${var.environment}"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "main"
  subnet_ids = var.private_subnets_rds

  tags = {
    Name = "${var.app_name} RDS Subnet Group"
  }
}

resource "aws_db_parameter_group" "dbpg" {
  name   = "pg-postgres-14"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "default" {
  identifier             = var.app_name
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "14.6"
  parameter_group_name   = aws_db_parameter_group.dbpg.name
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  username               = random_password.username.result
  password               = random_password.master_password.result
  skip_final_snapshot    = true
  multi_az               = var.multi_az
  vpc_security_group_ids = ["${aws_security_group.sg_rds.id}"]
}

resource "random_password" "master_password" {
  length  = 20
  special = false
  numeric = false
}

resource "random_password" "username" {
  length  = 6
  upper   = false
  special = false

}

resource "random_string" "secretname" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

resource "aws_secretsmanager_secret" "default" {
  kms_key_id  = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/secretsmanager"
  name        = "${var.app_name}-RDS-Credentials-test-${random_string.secretname.result}"
  description = "${var.app_name}-DO-NOT-REMOVE-RDS-Credentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = <<EOF
{
  "Username": "${random_password.username.result}",
  "Password": "${random_password.master_password.result}",
  "Engine": "${aws_db_instance.default.engine}",
  "Host": "${aws_db_instance.default.endpoint}",
  "Port": ${aws_db_instance.default.port}
}
EOF
}
