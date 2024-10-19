# Create an SSM parameter for the RDS endpoint
resource "aws_ssm_parameter" "db_host" {
  name  = "/${local.service_name}/${terraform.workspace}/db.host"
  type  = "String"
  value = split(":", aws_db_instance.rds.endpoint)[0]

  tags = {
    Name = "${local.name_prefix}-db-host"
  }
}
