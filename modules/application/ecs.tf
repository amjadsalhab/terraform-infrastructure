resource "aws_ecs_task_definition" "orders" {
  family                = "${var.environment}-orders"
  network_mode          = "bridge"
  cpu                   = "256"
  memory                = "256"
  requires_compatibilities = ["EC2"]
  task_role_arn         = "arn:aws:iam::472246201927:role/ECS-Task-Role"

  container_definitions = jsonencode([
    {
      name      = "orders-container"
      image     = "472246201927.dkr.ecr.us-east-1.amazonaws.com/${var.environment}-orders"
      cpu       = 256
      memory    = 256
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "ENVIRONMENT"
          value = "${var.environment}"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-create-group"   = "true"
          "awslogs-group"          = "${var.environment}-orders"
          "awslogs-region"         = "us-east-1"
          "awslogs-stream-prefix"  = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "users" {
  family                = "${var.environment}-users"
  network_mode          = "bridge"
  cpu                   = "256"
  memory                = "256"
  requires_compatibilities = ["EC2"]
  task_role_arn         = "arn:aws:iam::472246201927:role/ECS-Task-Role"

  container_definitions = jsonencode([
    {
      name      = "users-container"
      image     = "472246201927.dkr.ecr.us-east-1.amazonaws.com/${var.environment}-users"
      cpu       = 256
      memory    = 256
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "ENVIRONMENT"
          value = "${var.environment}"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-create-group"   = "true"
          "awslogs-group"          = "${var.environment}-users"
          "awslogs-region"         = "us-east-1"
          "awslogs-stream-prefix"  = "ecs"
        }
      }
    }
  ])
}