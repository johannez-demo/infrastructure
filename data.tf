data "aws_ssm_parameter" "db_username" {
  name = "/${local.service_name}/${terraform.workspace}/db.username"
}

data "aws_ssm_parameter" "db_password" {
  name = "/${local.service_name}/${terraform.workspace}/db.password"
}
