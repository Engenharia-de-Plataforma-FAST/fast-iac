# =============================================================================
# COMPUTE MODULE - EC2 Instances (Bastion and Web Servers)
# =============================================================================

# =============================================================================
# DATA SOURCES
# =============================================================================

data "aws_ami" "instance_ami" {
  most_recent = true
  owners      = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.instance_ami]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# =============================================================================
# SSH KEY PAIR
# =============================================================================

resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "main" {
  key_name   = "${var.name_prefix}-keypair"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-keypair"
    }
  )
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "${path.root}/${var.name_prefix}-key.pem"
  file_permission = "0400"
}

# =============================================================================
# BASTION HOST
# =============================================================================

resource "aws_instance" "bastion" {
  count = var.create_bastion ? 1 : 0

  ami                    = data.aws_ami.instance_ami.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[0]
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [var.bastion_security_group_id]

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-bastion"
      Role = "Bastion"
    }
  )
}

# =============================================================================
# WEB SERVERS
# =============================================================================

resource "aws_instance" "web" {
  count = var.web_server_count

  ami                    = data.aws_ami.instance_ami.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [var.web_security_group_id]

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-web-${count.index + 1}"
      Role = "WebServer"
    }
  )
}
