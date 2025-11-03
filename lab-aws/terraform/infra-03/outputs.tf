# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.networking.internet_gateway_id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.networking.nat_gateway_id
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = module.networking.nat_gateway_ip
}

# =============================================================================
# SECURITY OUTPUTS
# =============================================================================

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = module.security.bastion_security_group_id
}

output "web_security_group_id" {
  description = "Web servers security group ID"
  value       = module.security.web_security_group_id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security.alb_security_group_id
}

# =============================================================================
# COMPUTE OUTPUTS
# =============================================================================

output "bastion_instance_id" {
  description = "Bastion host instance ID"
  value       = module.compute.bastion_instance_id
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.compute.bastion_public_ip
}

output "bastion_public_dns" {
  description = "Bastion host public DNS"
  value       = module.compute.bastion_public_dns
}

output "web_instance_ids" {
  description = "List of web server instance IDs"
  value       = module.compute.web_instance_ids
}

output "web_private_ips" {
  description = "List of web server private IPs"
  value       = module.compute.web_private_ips
}

output "key_pair_name" {
  description = "SSH key pair name"
  value       = module.compute.key_pair_name
}

output "private_key_path" {
  description = "Path to private SSH key file"
  value       = module.compute.private_key_path
}

output "ami_id" {
  description = "AMI ID used for instances"
  value       = module.compute.ami_id
}

# =============================================================================
# LOAD BALANCER OUTPUTS
# =============================================================================

output "load_balancer_dns_name" {
  description = "Load balancer DNS name"
  value       = module.load_balancer.load_balancer_dns_name
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value       = "http://${module.load_balancer.load_balancer_dns_name}"
}

output "load_balancer_zone_id" {
  description = "Load balancer hosted zone ID"
  value       = module.load_balancer.load_balancer_zone_id
}

# =============================================================================
# CONNECTION COMMANDS
# =============================================================================

output "ssh_bastion_command" {
  description = "SSH command to connect to bastion host"
  value       = var.create_bastion ? "ssh -o IdentitiesOnly=yes -i ${module.compute.private_key_path} ec2-user@${module.compute.bastion_public_ip}" : "Bastion host not created"
}

output "ssh_web_servers_commands" {
  description = "SSH commands to connect to web servers via bastion"
  value = var.create_bastion ? [
    for idx, ip in module.compute.web_private_ips :
    "ssh -o IdentitiesOnly=yes -i ${module.compute.private_key_path} -o ProxyCommand='ssh -o IdentitiesOnly=yes -i ${module.compute.private_key_path} -W %h:%p ec2-user@${module.compute.bastion_public_ip}' ec2-user@${ip}"
  ] : ["Bastion host required for SSH access to web servers"]
}

# =============================================================================
# AWS ACCOUNT INFO
# =============================================================================

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used"
  value       = var.region
}
