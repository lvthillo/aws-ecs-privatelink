resource "aws_ecs_cluster" "ecs_cluster" {
  #checkov:skip=CKV_AWS_65:For this demo I don't need container insights enabled
  name = var.ecs_cluster_name
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_service_count
  network_configuration {
    assign_public_ip = false
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = var.ecs_subnets
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.ecs_container_name
    container_port   = var.ecs_port
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.ecs_task_def_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  container_definitions = jsonencode([
    {
      name      = var.ecs_container_name
      image     = var.ecs_docker_image
      cpu       = var.ecs_task_cpu //to fix naming
      memory    = var.ecs_task_memory
      essential = true
      portMappings = [
        {
          containerPort = var.ecs_port //containerPort and hostPort are the same in awsvpc network mode
        }
      ]
    }
  ])
}

resource "aws_security_group" "ecs_sg" {
  name        = var.ecs_sg_name
  description = var.ecs_sg_description
  vpc_id      = var.vpc_id
  tags = {
    Name = var.ecs_sg_name
  }
}

resource "aws_security_group_rule" "ingress" {
  type                     = "ingress"
  description              = "Allow ALB to ECS"
  from_port                = var.ecs_port
  to_port                  = var.ecs_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = var.alb_sg
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  description       = "Allow ECS to pull image"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}