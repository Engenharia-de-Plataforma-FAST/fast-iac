data "aws_caller_identity" "current" {}

data "aws_ami" "fast_ami" {
    most_recent = true
    filter {
        name   = "name"
        values = [var.instance_ami]
    }
    owners = [data.aws_caller_identity.current.account_id]

    # Get the ID below from https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#AMICatalog:
    # aws ec2 describe-images --owner amazon --image-ids ami-066784287e358dad1 --profile batatinha |jq
    # owners = ["amazon"]
}

resource "tls_private_key" "fast_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
    key_name   = var.key_name
    public_key = tls_private_key.fast_key.public_key_openssh
}

resource "aws_instance" "fast" {
  ami                           = data.aws_ami.fast_ami.id
  instance_type                 = var.instance_type
  key_name                      = aws_key_pair.generated_key.key_name
  security_groups               = [aws_security_group.fast_sg.id]
  private_ip                    = "10.0.1.100"
  subnet_id                     = aws_subnet.public_subnet.id
  associate_public_ip_address   = true

  tags = {
    Name = "nginx"
  }
}

output "private_key" {
  value     = tls_private_key.fast_key.private_key_pem
  sensitive = true
}
