output "bastion_public_ip" {
  value = length(aws_instance.bastion) > 0 ? aws_instance.bastion[0].public_ip : "n/a"
}

output "web_public_ip" {
  value = length(aws_instance.web) > 0 ? aws_instance.web[0].public_ip : "n/a"
}

output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}
