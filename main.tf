data "aws_vpc" "selected" {
  id = "vpc-0cfbad9b2748e971f"
}

data "aws_subnet" "selected" {
  id = "subnet-0384a547b2896fb03"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg-2"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-web-sg-2"
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = data.aws_subnet.selected.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  user_data = <<EOF
#!/bin/bash
sudo yum install httpd -y
echo "Hola Mundo desde Terraform con Data Sources" > /var/www/html/index.html
sudo systemctl enable --now httpd
EOF

  tags = {
    Name = "web-datasource"
  }
}
