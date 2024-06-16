
ssh_private_key_file = "~/.ssh/id_ed25519"
ssh_public_key = "centos:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItUe86vnf93GZy2ISNc/o88whg0R8817qvWhK6u/kFL"

region = "us-east-1"
instance_type = "t3.micro"
subnet_id = "subnet-005bb1cceebc0371e"
ssh_username = "ec2-user"

ansible_playbook_path = "../ansible/main.yml"

image_name = "fast"
image_description = "FAST Image"