resource "aws_lb" "application_lb" {
  name               = "${var.environment}-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.application_lb_sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-application-lb"
  }
}

resource "aws_security_group" "application_lb_sg" {
  name        = "${var.environment}-application-lb-sg"
  description = "Security group for the application load balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Name        = "application-lb-sg-${var.environment}"
  }
}

