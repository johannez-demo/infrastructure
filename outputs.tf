output "bastion_public_ip" {
  value = length(aws_instance.bastion) > 0 ? aws_instance.bastion[0].public_ip : "n/a"
}

output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "ecs_task_public_ip" {
  value = data.aws_ecs_task.main.network_interface[0].public_ip
}
