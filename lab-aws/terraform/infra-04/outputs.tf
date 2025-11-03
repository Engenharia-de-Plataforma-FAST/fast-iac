# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.igw_id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "nat_gateway_ips" {
  description = "NAT Gateway public IPs"
  value       = module.vpc.nat_public_ips
}

# =============================================================================
# SECURITY OUTPUTS
# =============================================================================

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = var.create_bastion ? module.bastion_sg[0].security_group_id : null
}

output "web_security_group_id" {
  description = "Web servers security group ID"
  value       = module.web_sg.security_group_id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.alb_sg.security_group_id
}

# =============================================================================
# COMPUTE OUTPUTS
# =============================================================================

output "bastion_instance_id" {
  description = "Bastion host instance ID"
  value       = var.create_bastion ? module.bastion[0].id : null
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = var.create_bastion ? module.bastion[0].public_ip : null
}

output "bastion_public_dns" {
  description = "Bastion host public DNS"
  value       = var.create_bastion ? module.bastion[0].public_dns : null
}

output "web_instance_ids" {
  description = "List of web server instance IDs"
  value       = [for instance in module.web_servers : instance.id]
}

output "web_private_ips" {
  description = "List of web server private IPs"
  value       = [for instance in module.web_servers : instance.private_ip]
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

# =============================================================================
# LOAD BALANCER OUTPUTS
# =============================================================================

output "load_balancer_dns_name" {
  description = "Load balancer DNS name"
  value       = module.alb.dns_name
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value       = "http://${module.alb.dns_name}"
}

output "load_balancer_zone_id" {
  description = "Load balancer hosted zone ID"
  value       = module.alb.zone_id
}

output "load_balancer_arn" {
  description = "Load balancer ARN"
  value       = module.alb.arn
}

# =============================================================================
# CONNECTION COMMANDS
# =============================================================================

output "ssh_bastion_command" {
  description = "SSH command to connect to bastion host"
  value       = var.create_bastion ? "ssh -o IdentitiesOnly=yes -i ${local_file.private_key.filename} ec2-user@${module.bastion[0].public_ip}" : "Bastion host not created"
}

output "ssh_web_servers_commands" {
  description = "SSH commands to connect to web servers via bastion"
  value = var.create_bastion ? [
    for idx, instance in module.web_servers :
    "ssh -o IdentitiesOnly=yes -i ${local_file.private_key.filename} -o ProxyCommand='ssh -o IdentitiesOnly=yes -i ${local_file.private_key.filename} -W %h:%p ec2-user@${module.bastion[0].public_ip}' ec2-user@${instance.private_ip}"
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
