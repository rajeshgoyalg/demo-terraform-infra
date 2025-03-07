resource "aws_ecs_cluster" "demo_devops_cluster" {
  name = "demo-devops-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_ecs_task_definition" "demo_flask_app_task" {
  family                   = "demo-flask-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "demo-flask-app"
    image     = "rajeshgoyalg/demo-flask-app:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

resource "aws_ecs_service" "demo_flask_service" {
  name            = "demo-flask-service"
  cluster         = aws_ecs_cluster.demo_devops_cluster.id
  task_definition = aws_ecs_task_definition.demo_flask_app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.demo_devops_tg.arn
    container_name   = "demo-flask-app"
    container_port   = 3000
  }
}