resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_ecs_cluster" "main" {
  name = "friendica-cluster"
}

/*
data "template_file" "friendica_app" {
  template = file("./templates/ecs/friendica_app.json.tpl")

  vars = {
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
  }
}
*/

resource "aws_ecs_task_definition" "friendica" {
  family                   = "friendica-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = jsonencode([{
    name  = "friendica-app"
    image = "friendica:2023.12-apache"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}


resource "aws_ecs_service" "friendica" {
  name            = "friendica-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.friendica.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "friendica-app"
    container_port   = var.app_port
  }
   
}