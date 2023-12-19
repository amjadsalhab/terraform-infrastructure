resource "aws_instance" "mysql" {
  ami           = "ami-0068d7451cf00173c"
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets[0]

  vpc_security_group_ids = [aws_security_group.mysql_sg.id,"sg-0a0e94eddc865eae0"]

  tags = {
    Name        = "${var.environment}-mysql-ec2-instance"
    Environment = var.environment
  }
}

resource "aws_security_group" "mysql_sg" {
  name        = "${var.environment}-mysql-sg"
  description = "Security group for MySQL access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr, "188.161.184.40/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-mysql-sg"
    Environment = var.environment
  }
}

resource "aws_route53_record" "dns_record" {
  zone_id = "Z0719936LWNSUHYQY8CX"
  name    = "${var.environment}-mysql.amjad-salhab.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.mysql.public_ip]
}

resource "aws_dlm_lifecycle_policy" "ec2_dlm_backup" {
  description        = "Daily AMI policy"
  execution_role_arn = "arn:aws:iam::472246201927:role/AWSDataLifecycleManagerDefaultRole"
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]

    schedule {
      name = "DailySnapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["02:00"]
      }

      retain_rule {
        count = 1
      }

      tags_to_add = {
        "SnapshotCreator" = "DLM"
      }

      copy_tags = true
    }

    target_tags = {
      Name        = "${var.environment}-mysql-ec2-instance"
      Environment = var.environment
    }
  }
}

