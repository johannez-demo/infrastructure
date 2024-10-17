data "aws_ssm_parameter" "db_username" {
  name = "/demo/dev/db.username"
}

data "aws_ssm_parameter" "db_password" {
  name = "/demo/dev/db.password"
}
