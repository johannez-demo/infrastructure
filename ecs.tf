# Create ECS Cluster
resource "aws_ecs_cluster" "this" {
  count = terraform.workspace == "prod" ? 1 : 0
  name  = "${local.name_prefix}-ecs-cluster"
}

# Create ECS Task Definition for micro containers
resource "aws_ecs_task_definition" "micro" {
  count                    = terraform.workspace == "prod" ? 1 : 0
  family                   = "${local.name_prefix}-td-micro"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role[0].arn
  task_role_arn            = aws_iam_role.ecs_task_role[0].arn

  container_definitions = jsonencode([
    {
      name      = "${local.name_prefix}-container-micro"
      image     = "ghcr.io/johannez-demo/wordpress:latest"
      essential = true
      memory    = 512
      cpu       = 256
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "WORDPRESS_DB_HOST"
          value = split(":", aws_db_instance.rds.endpoint)[0]
        },
        {
          name  = "WORDPRESS_DB_NAME"
          value = local.service_name
        },
        {
          name  = "WORDPRESS_DB_USER"
          value = data.aws_ssm_parameter.db_username.value
        },
        {
          name  = "WORDPRESS_DB_PASSWORD",
          value = data.aws_ssm_parameter.db_password.value,
        },
        {
          name  = "WORDPRESS_DEBUG",
          value = "1",
        },
      ]
    }
  ])
}

# Create ECS Service Security Group
resource "aws_security_group" "ecs" {
  count       = terraform.workspace == "prod" ? 1 : 0
  name        = "${local.name_prefix}-ecs-service-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from anywhere
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS traffic from anywhere
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${local.name_prefix}-ecs-service-sg"
  }
}

# Create ECS Service
resource "aws_ecs_service" "this" {
  count           = terraform.workspace == "prod" ? 1 : 0
  name            = "${local.name_prefix}-ecs-service"
  cluster         = aws_ecs_cluster.this[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.micro[0].arn

  network_configuration {
    subnets          = [aws_subnet.public_a.id]
    security_groups  = [aws_security_group.ecs[0].id]
    assign_public_ip = true
  }

  tags = {
    Name = "${local.name_prefix}-ecs-service"
  }
}

