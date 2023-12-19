resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment}-cluster"
}

resource "aws_launch_template" "lt" {
  name          = "${var.environment}-lt"
  image_id      = "ami-045a946a7171d63ce"
  instance_type = "t2.micro"
  key_name      = "devops"
  iam_instance_profile {
    arn = "arn:aws:iam::472246201927:instance-profile/ec2-ecs-role"
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["sg-096a7aff960e2b9a5", "sg-0c29bac1d1572dced"]
  }
  user_data = base64encode(<<-EOF
#!/bin/bash
echo hi > /home/ec2-user/hi.txt
echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  min_size             = 1
  max_size             = 25
  #desired_capacity     = 10
  vpc_zone_identifier  = var.public_subnets

  protect_from_scale_in = true

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "MyAsgCapacityProvider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1000
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
    weight            = 1
    base              = 0
  }
}