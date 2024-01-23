provider "aws" {
  region = var.aws_region # You can change this to your preferred AWS region
}


resource "aws_default_vpc" "my-vpc" {   # This is the default VPC
  tags = {
    Name = "my-vpc"
  }
  
}

terraform {
  backend "s3" {
    bucket = "mybucket"       # Will be overridden from build
    key    = "path/to/my/key" # Will be overridden from build
    region = "us-east-1"
  }
}

resource "aws_security_group" "my-sec-group" {
    name        = "my-sec-group"
    description = "My security group"
    vpc_id      = aws_default_vpc.my-vpc.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "my-ec2-instance" {
    ami           = data.aws_ami.ubuntu.id # Replace with the desired AMI ID
    instance_type = var.instance_type
    key_name      =  "default-ec2" # Replace with the name of your key pair
    security_groups = [ aws_security_group.my-sec-group.id  ]
    subnet_id = data.aws_subnets.my-subnets.ids[0]

    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y httpd",
            "sudo yum docker -y",
            "sudo systemctl start httpd",
            "sudo systemctl enable httpd"
        ]
    }

    connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = file(var.aws_key_pair)  # Replace with the path to your private key
        host        = self.public_ip
    }

    tags = {
        Name = "my-ec2-instance"
    }
}