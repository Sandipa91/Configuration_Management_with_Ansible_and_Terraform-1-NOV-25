terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.23.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
  
}

# Generate an SSH key pair automatically
resource "tls_private_key" "key2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key in local directory
resource "local_file" "private_key" {
  content         = tls_private_key.key2.private_key_pem
  filename        = "${path.module}/ec2-key.pem"
  file_permission = "0400"
}

# Create AWS key pair
resource "aws_key_pair" "generated_key" {
  key_name   = "tf-lab-key-new"
  public_key = tls_private_key.key2.public_key_openssh
}



resource "aws_security_group" "allow_all" {
  name        = "allow-all-sg"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"        # all protocols
    cidr_blocks = ["0.0.0.0/0"]   # allow all IPv4
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




# Launch EC2 instance
resource "aws_instance" "vm" {
  ami                         = "ami-0ecb62995f68bb549" # Ubuntu 22.04 (us-east-1)
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.generated_key.key_name  
  vpc_security_group_ids = [aws_security_group.allow_all.id]

  tags = {
    Name = "TerraformAutomationVM"
  }
}
