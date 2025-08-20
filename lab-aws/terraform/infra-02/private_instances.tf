data "aws_availability_zones" "available_for_private" {
  state = "available"
}

resource "aws_instance" "web_server_1" {
  ami                      = data.aws_ami.fast_ami.id
  instance_type            = var.instance_type
  key_name                 = aws_key_pair.bastion_keypair.key_name
  vpc_security_group_ids   = [aws_security_group.web_sg.id]
  subnet_id                = aws_subnet.private_subnet_a.id
  associate_public_ip_address = false

  tags = {
    Name = "${local.name_prefix}-web-server-1"
    Role = "WebServer"
    AZ   = data.aws_availability_zones.available_for_private.names[0]
  }
}

resource "aws_instance" "web_server_2" {
  ami                      = data.aws_ami.fast_ami.id
  instance_type            = var.instance_type
  key_name                 = aws_key_pair.bastion_keypair.key_name
  vpc_security_group_ids   = [aws_security_group.web_sg.id]
  subnet_id                = aws_subnet.private_subnet_b.id
  associate_public_ip_address = false

  tags = {
    Name = "${local.name_prefix}-web-server-2"
    Role = "WebServer"
    AZ   = data.aws_availability_zones.available_for_private.names[1]
  }
}