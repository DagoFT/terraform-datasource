data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet_ids.selected.ids[0]

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
