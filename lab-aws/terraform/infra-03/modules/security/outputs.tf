output "bastion_security_group_id" {
  description = "Bastion host security group ID"
  value       = var.create_bastion_sg ? aws_security_group.bastion[0].id : null
}

output "web_security_group_id" {
  description = "Web server security group ID"
  value       = var.create_web_sg ? aws_security_group.web[0].id : null
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = var.create_alb_sg ? aws_security_group.alb[0].id : null
}
