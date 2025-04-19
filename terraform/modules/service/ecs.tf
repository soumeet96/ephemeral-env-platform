resource "aws_ecs_cluster" "dev" {
  name = "${var.app_name}-${var.branch_name}-cluster"
  tags = {
    Name        = "${var.app_name}-${var.branch_name}-cluster"
  }
}

resource "aws_ecs_task_definition" "dev" {
  family                   = "${var.app_name}-${var.branch_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.container_image
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        {
          name  = "BRANCH_NAME"
          value = var.branch_name
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "dev" {
  name            = "${var.app_name}-${var.branch_name}-svc"
  cluster         = aws_ecs_cluster.dev.id
  task_definition = aws_ecs_task_definition.dev.arn
  desired_count   = 1

  platform_version = "LATEST"

  network_configuration {
    subnets         = var.private_subnets
    assign_public_ip = true
    security_groups  = [var.security_group_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dev.arn
    container_name   = "app"
    container_port   = 8080
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = {
    Name        = "${var.app_name}-${var.branch_name}"
    destroy_at  = timeadd(timestamp(), "${var.destroy_after_secs}s")
  }
}