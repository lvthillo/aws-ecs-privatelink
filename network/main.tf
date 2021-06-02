provider "aws" {
    region = "eu-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.100.100.0/24"
}

resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.100.100.0/25"

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.100.100.128/25"

  tags = {
    Name = "subnet-2"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
}

resource "aws_ecs_service" "myapp" {
  name            = "test-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.myapp.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  #iam_role        = aws_iam_role.foo.arn
  #depends_on      = [aws_iam_role_policy.foo]
   network_configuration {
    assign_public_ip = false

    security_groups = [aws_security_group.lb_sg.id]

    subnets = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.test.arn
    container_name   = "myapp"
    container_port   = 80
  }
}

//task
resource "aws_ecs_task_definition" "myapp" {
  family = "myapp"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  container_definitions = jsonencode([
    {
      name      = "myapp"
      image     = "nginx"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  /*access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }*/

  tags = {
    Environment = "test"
  }
}

//sg voor LB
resource "aws_security_group" "lb_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] //NLB!
  }

  tags = {
    Name = "allow_http"
  }
}

//targetgroup voor LB
resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id
}

resource "aws_alb_listener" "myapp" {
  load_balancer_arn = aws_lb.test.arn
  port = "80"
  protocol = "HTTP" #Cert for HTTPS

  default_action {
    target_group_arn = aws_lb_target_group.test.arn
    type = "forward"
  }
}

###
#VPC
resource "aws_vpc" "main" {
  cidr_block = "10.100.200.0/24"
}


#VPC ENDPOINT


#NLB
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true
  load_balancer_type = "network"
  subnets            = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
}

# lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "populate_NLB_TG_with_ALB.zip"
  function_name = "populate"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "populate_NLB_TG_with_ALB.lambda_handler"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  timeout          = 300

  # VPC?
  runtime = "python2.7"

  environment {
    variables = {
      ALB_DNS_NAME = "bar"
      NLB_TG_ARN = ""
      S3_BUCKET = ""
      MAX_LOOKUP_PER_INVOCATION  = ""
      INVOCATIONS_BEFORE_DEREGISTRATION = ""
      CW_METRIC_FLAG_IP_COUNT = ""
      ALB_LISTENER = ""
    }
  }
}