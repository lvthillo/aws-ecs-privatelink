provider "aws" {
    region = "eu-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.100.100.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "subnet_1a_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.100.100.0/26"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "subnet-1a-public"
  }
}

resource "aws_subnet" "subnet_1b_public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.100.100.64/26"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "subnet-1b-public"
  }
}

resource "aws_subnet" "subnet_1a_private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.100.100.128/26"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "subnet-1a-private"
  }
}

resource "aws_subnet" "subnet_1b_private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.100.100.192/26"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "subnet-1b-private"
  }
}

# ALB
resource "aws_lb" "test-alb" {
  name               = "test-alb-tf"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.subnet_1a_private.id, aws_subnet.subnet_1b_private.id]
}

# ALB SGR
resource "aws_security_group" "alb_sg" {
  name        = "allow_http_alb"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from NLB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    #security_groups  = [aws_security_group.nlb_sg.id]
    cidr_blocks      = ["0.0.0.0/0"] 
  }

  egress {
    description      = "Egress ALB to ECS"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}

# NLB
resource "aws_lb" "test-nlb" {
  name               = "test-nlb-tf"
  internal           = true
  load_balancer_type = "network"
  #security_groups    = [aws_security_group.nlb_sg.id]
  subnets            = [aws_subnet.subnet_1a_private.id, aws_subnet.subnet_1b_private.id]
}

# resource "aws_security_group" "nlb_sg" {
#   name        = "allow_http"
#   description = "Allow HTTP inbound traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description      = "HTTP from endpoint"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"] //ENDPOINT?! 
#   }
# }

# lambda role
data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "terraform_function_role"
  assume_role_policy = "${data.aws_iam_policy_document.AWSLambdaTrustPolicy.json}"
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            "Sid": "LambdaLogging",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        },
        {
            "Sid": "S3",
            "Action": [
                "s3:Get*",
                "s3:PutObject",
                "s3:CreateBucket",
                "s3:ListBucket",
                "s3:ListAllMyBuckets"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "ELB",
            "Action": [
                "elasticloadbalancing:Describe*",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "CW",
            "Action": [
                "cloudwatch:putMetricData"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
  })
}


# lambda
resource "aws_lambda_function" "test_lambda" {
  filename      = "populate_NLB_TG_with_ALB.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.test"

  source_code_hash = filebase64sha256("./populate_NLB_TG_with_ALB.zip")

  runtime = "python2.7"
  timeout = 300

  environment {
    variables = {
      ALB_DNS_NAME = aws_lb.test-alb.dns_name
      ALB_LISTENER = 80
      INVOCATIONS_BEFORE_DEREGISTRATION = 3
      MAX_LOOKUP_PER_INVOCATION = 50
      NLB_TG_ARN = aws_lb.test-nlb.arn
      S3_BUCKET = aws_s3_bucket.bucket.id
      CW_METRIC_FLAG_IP_COUNT = true
    }
  }
}

# S3 Bucket for lambda
resource "aws_s3_bucket" "bucket" {
  bucket = "lvthillo-lambda-bucket"
  acl    = "private"
  tags = {
    Name        = "lvthillo-lambda-bucket"
  }
}

# ECS stuff
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

    security_groups = [aws_security_group.ecs_sg.id]

    subnets = [aws_subnet.subnet_1a_private.id, aws_subnet.subnet_1b_private.id]
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

//targetgroup voor LB
resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.main.id
}

resource "aws_alb_listener" "myapp" {
  load_balancer_arn = aws_lb.test-alb.arn
  port = "80"
  protocol = "HTTP" #Cert for HTTPS

  default_action {
    target_group_arn = aws_lb_target_group.test.arn
    type = "forward"
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "allow_http_lb"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "Allow ALB to ECS"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] //sgr van ALB!
  }

  egress {
    description      = "Allow ALB to ECS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] //sgr van ALB!
  }

  tags = {
    Name = "allow_http_ecs"
  }
}

# Public RT
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.gw.id
#   }

  tags = {
    Name = "public_route_table"
  }
}

# Private RT
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }


  tags = {
    Name = "private_route_table"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet_1a_public.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table_association" "rta_subnet_public_1a" {
  subnet_id      = aws_subnet.subnet_1a_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "rta_subnet_public_1b" {
  subnet_id      = aws_subnet.subnet_1b_public.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "rta_subnet_private_1a" {
  subnet_id      = aws_subnet.subnet_1a_private.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "rta_subnet_private_1b" {
  subnet_id      = aws_subnet.subnet_1b_private.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_cloudwatch_event_rule" "every_minute" {
    name = "every-five-minutes"
    description = "Fires every minute"
    schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_minute" {
    rule = "${aws_cloudwatch_event_rule.every_minute.name}"
    target_id = "test_lambda"
    arn = "${aws_lambda_function.test_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.test_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_minute.arn}"
}