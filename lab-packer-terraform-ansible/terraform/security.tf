resource "aws_security_group" "fast_sg" {
    name = "fast-sg"
    vpc_id = aws_vpc.fast_vpc.id
    ingress {
        cidr_blocks = [
            "200.133.0.86/32"
        ]
        from_port = 22
        to_port = 22
        protocol = "tcp"
    }

    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }

    ingress {
        cidr_blocks = [
            "0.0.0.0/0"
        ]
        from_port = -1
        to_port = -1
        protocol = "icmp"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name = "fast-sg"
  }

}

