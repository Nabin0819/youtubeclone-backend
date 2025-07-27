terraform { 
required_providers { 
aws = { 
source  = "hashicorp/aws" 
version = "~> 4.16" 
} 
} 
required_version = ">= 1.2.0" 
} 
provider "aws" { 
region = var.region 
} 
resource "aws_security_group" "icecake_sg1" { 
name        
= "icecake_sg1" 
description = "Allow SSH and 8080 access" 
ingress { 
from_port   = 22 
to_port     
= 22 
protocol    = "tcp" 
cidr_blocks = ["0.0.0.0/0"] 
} 
ingress { 
from_port   = 5000 
to_port     
= 5000 
protocol    = "tcp" 
cidr_blocks = ["0.0.0.0/0"] 
description = "Backend (Node/Spring) API" 
  } 
 
  ingress { 
    from_port   = 3000 
    to_port     = 3000 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
    description = "React Frontend" 
  } 
 
  ingress { 
    from_port   = 80 
    to_port     = 80 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
    description = "HTTP (Nginx)" 
  } 
 
  egress { 
    from_port   = 0 
    to_port     = 0 
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
  } 
} 
 
resource "aws_instance" "icecake_server" { 
  ami           = var.ami_id 
  instance_type = var.instance_type 
  key_name      = var.key_pair_name 
 
  security_groups = [aws_security_group.icecake_sg1.name] 
 
  tags = { 
    Name = "Icecake_Server" 
  } 
}
