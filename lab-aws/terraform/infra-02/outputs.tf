# =============================================================================
# BASTION HOST OUTPUTS
# =============================================================================

output "bastion_instance_id" {
  description = "Bastion host instance ID"
  value       = aws_instance.bastion_host.id
}

output "bastion_public_ip" {
  description = "Bastion host public IP address"
  value       = aws_instance.bastion_host.public_ip
}

output "bastion_public_dns" {
  description = "Bastion host public DNS name"
  value       = aws_instance.bastion_host.public_dns
}

# =============================================================================
# WEB SERVERS OUTPUTS
# =============================================================================

output "web_server_1_id" {
  description = "Web server 1 instance ID"
  value       = aws_instance.web_server_1.id
}

output "web_server_1_private_ip" {
  description = "Web server 1 private IP address"
  value       = aws_instance.web_server_1.private_ip
}

output "web_server_2_id" {
  description = "Web server 2 instance ID"
  value       = aws_instance.web_server_2.id
}

output "web_server_2_private_ip" {
  description = "Web server 2 private IP address"
  value       = aws_instance.web_server_2.private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

# =============================================================================
# NETWORK OUTPUTS
# =============================================================================

output "public_subnet_a_id" {
  description = "Public subnet A ID"
  value       = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  description = "Public subnet B ID"
  value       = aws_subnet.public_subnet_b.id
}

output "private_subnet_a_id" {
  description = "Private subnet A ID"
  value       = aws_subnet.private_subnet_a.id
}

output "private_subnet_b_id" {
  description = "Private subnet B ID"
  value       = aws_subnet.private_subnet_b.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat_gateway.public_ip
}

# =============================================================================
# LOAD BALANCER OUTPUTS
# =============================================================================

output "load_balancer_dns" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.web_alb.dns_name
}

output "load_balancer_url" {
  description = "Application Load Balancer URL"
  value       = "http://${aws_lb.web_alb.dns_name}"
}

output "load_balancer_zone_id" {
  description = "Application Load Balancer hosted zone ID"
  value       = aws_lb.web_alb.zone_id
}

# =============================================================================
# SECURITY GROUP OUTPUTS
# =============================================================================

output "bastion_security_group_id" {
  description = "Bastion host security group ID"
  value       = aws_security_group.bastion_sg.id
}

output "web_security_group_id" {
  description = "Web servers security group ID"
  value       = aws_security_group.web_sg.id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb_sg.id
}

# =============================================================================
# CONNECTION COMMANDS
# =============================================================================

output "ssh_bastion_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -o IdentitiesOnly=yes -i ${path.module}/${var.key_name}.pem ec2-user@${aws_instance.bastion_host.public_ip}"
}

output "ssh_web_server_1_command" {
  description = "SSH command to connect to web server 1 via bastion"
  value       = "ssh -o IdentitiesOnly=yes -i ${path.module}/${var.key_name}.pem -o ProxyCommand='ssh -o IdentitiesOnly=yes -i ${path.module}/${var.key_name}.pem -W %h:%p ec2-user@${aws_instance.bastion_host.public_ip}' ec2-user@${aws_instance.web_server_1.private_ip}"
}

output "ssh_web_server_2_command" {
  description = "SSH command to connect to web server 2 via bastion"
  value       = "ssh -o IdentitiesOnly=yes -i ${path.module}/${var.key_name}.pem -o ProxyCommand='ssh -o IdentitiesOnly=yes -i ${path.module}/${var.key_name}.pem -W %h:%p ec2-user@${aws_instance.bastion_host.public_ip}' ec2-user@${aws_instance.web_server_2.private_ip}"
}

output "ami_id" {
  description = "AMI ID used"
  value       = data.aws_ami.fast_ami.id
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used"
  value       = var.region
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private.id
}

output "key_pair_name" {
  description = "AWS Key Pair name"
  value       = aws_key_pair.bastion_keypair.key_name
}

output "private_key_path" {
  description = "Local path to private key file"
  value       = "${path.module}/${var.key_name}.pem"
}

