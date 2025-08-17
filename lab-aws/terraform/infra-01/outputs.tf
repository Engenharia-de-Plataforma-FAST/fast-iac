# =============================================================================
# WEB SERVER OUTPUTS
# =============================================================================

output "instance_id" {
  description = "Web server instance ID"
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "Web server public IP address"
  value       = aws_instance.web_server.public_ip
}

output "instance_public_dns" {
  description = "Web server public DNS name"
  value       = aws_instance.web_server.public_dns
}

output "web_server_url" {
  description = "Web server URL"
  value       = "http://${aws_instance.web_server.public_ip}"
}

# =============================================================================
# NETWORK OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public_subnet.id
}

output "subnet_availability_zone" {
  description = "Availability zone of the public subnet"
  value       = aws_subnet.public_subnet.availability_zone
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

# =============================================================================
# SECURITY & ACCESS OUTPUTS
# =============================================================================

output "security_group_id" {
  description = "Web server security group ID"
  value       = aws_security_group.web_sg.id
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = "ssh -i ${path.module}/${var.key_name}.pem ec2-user@${aws_instance.web_server.public_ip}"
}

output "key_pair_name" {
  description = "AWS Key Pair name"
  value       = aws_key_pair.web_server_keypair.key_name
}

output "private_key_path" {
  description = "Local path to private key file"
  value       = "${path.module}/${var.key_name}.pem"
}

# =============================================================================
# AMI & ACCOUNT INFO
# =============================================================================

output "ami_id" {
  description = "AMI ID used"
  value       = data.aws_ami.web_server_ami.id
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used"
  value       = var.region
}