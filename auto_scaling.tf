/*

resource "aws_iam_role" "ecs_auto_scale_role" {
  name = "ecs_auto_scale_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_auto_scale_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_auto_scale_role.name
}



resource "aws_ecs_service" "friendica" {
  name            = "friendica-service"
  cluster         = aws_ecs_cluster.friendica.id
  task_definition = aws_ecs_task_definition.friendica.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets = aws_subnet.public.*.id
    security_groups = [aws_security_group.lb.id]
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.
    container_name   = "app-container"
    container_port   = 80
  }

  depends_on = [
    aws_ecs_task_definition.friendica,
    aws_alb_target_group.app,
  ]

  tags = {
    Name = "friendica-service"
  }
}

  # Other service configuration...


resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = aws_iam_role.ecs_auto_scale_role.arn
  min_capacity       = 1
  max_capacity       = 2
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up" {
  name               = "friendica_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down" {
  name               = "friendica_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

*/