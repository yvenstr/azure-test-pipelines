variable "aws_key_pair" {
  type    = string
  default = "./default-ec2.pem" // This is the name of the key pair file
  
}

variable "aws_region" {
  type    = string
  default = "us-east-1" // You can change this to your preferred AWS region
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

data "aws_subnets" "my-subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.my-vpc.id]
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # Canonical
}
