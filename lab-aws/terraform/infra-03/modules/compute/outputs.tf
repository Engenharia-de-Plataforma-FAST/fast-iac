output "bastion_instance_id" {
  description = "Bastion host instance ID"
  value       = var.create_bastion ? aws_instance.bastion[0].id : null
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = var.create_bastion ? aws_instance.bastion[0].public_ip : null
}

output "bastion_public_dns" {
  description = "Bastion host public DNS"
  value       = var.create_bastion ? aws_instance.bastion[0].public_dns : null
}

output "web_instance_ids" {
  description = "List of web server instance IDs"
  value       = aws_instance.web[*].id
}

output "web_private_ips" {
  description = "List of web server private IPs"
  value       = aws_instance.web[*].private_ip
}

output "key_pair_name" {
  description = "SSH key pair name"
  value       = aws_key_pair.main.key_name
}

output "private_key_path" {
  description = "Path to private SSH key file"
  value       = local_file.private_key.filename
}

output "ami_id" {
  description = "AMI ID used for instances"
  value       = data.aws_ami.instance_ami.id
}
