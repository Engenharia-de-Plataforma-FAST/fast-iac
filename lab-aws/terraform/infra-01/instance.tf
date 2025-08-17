data "aws_caller_identity" "current" {}

data "aws_ami" "web_server_ami" {
    most_recent = true
    filter {
        name   = "name"
        values = [var.instance_ami]
    }
    owners = [var.ami_owner == "self" ? data.aws_caller_identity.current.account_id : var.ami_owner]
}

resource "tls_private_key" "web_server_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "web_server_keypair" {
    key_name   = var.key_name
    public_key = tls_private_key.web_server_key.public_key_openssh
}

resource "local_file" "web_server_private_key" {
    content         = tls_private_key.web_server_key.private_key_pem
    filename        = "${path.module}/${var.key_name}.pem"
    file_permission = "0400"
}

resource "aws_instance" "web_server" {
  ami                           = data.aws_ami.web_server_ami.id
  instance_type                 = var.instance_type
  key_name                      = aws_key_pair.web_server_keypair.key_name
  vpc_security_group_ids        = [aws_security_group.web_sg.id]
  subnet_id                     = aws_subnet.public_subnet.id
  associate_public_ip_address   = true

  tags = {
    Name = "${local.name_prefix}-web-server"
    Role = "WebServer"
  }
}