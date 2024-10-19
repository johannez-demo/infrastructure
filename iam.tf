resource "aws_iam_role" "ecs_task_execution_role" {
  count = terraform.workspace == "prod" ? 1 : 0
  name  = "${local.name_prefix_camel}EcsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  count      = terraform.workspace == "prod" ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  count = terraform.workspace == "prod" ? 1 : 0
  name  = "${local.name_prefix_camel}EcsTaskRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_role_cloudwatch_logs_policy" {
  count = terraform.workspace == "prod" ? 1 : 0
  name  = "${local.name_prefix_camel}EcsTaskRoleCloudWatchLogsPolicy"
  role  = aws_iam_role.ecs_task_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:us-west-2:123456789012:log-group:/ecs/your-log-group:*"
      }
    ]
  })
}
