# Create bastion security group to allow SSH access
resource "aws_security_group" "bastion" {
  count       = terraform.workspace == "prod" ? 1 : 0
  name        = "${local.name_prefix}-bastion-sg"
  description = "Allow SSH access to bastion host"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.cidr_anywhere] # Allow SSH from anywhere (restrict in production)
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.cidr_anywhere]
  }

  tags = {
    Name = "${local.name_prefix}-bastion-sg"
  }
}

# Create the bastion host in the public subnet with MySQL client installed
resource "aws_instance" "bastion" {
  count = terraform.workspace == "prod" ? 1 : 0

  ami                    = var.ami_image_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.bastion[0].id]
  subnet_id              = aws_subnet.public_a.id
  key_name               = local.service_name

  tags = {
    Name = "${local.name_prefix}-bastion"
  }
}

resource "aws_security_group" "web" {
  count = terraform.workspace != "prod" ? 1 : 0

  name        = "${local.name_prefix}-web-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from anywhere
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.cidr_anywhere] # Allow SSH from anywhere (restrict in production)
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${local.name_prefix}-web-sg"
  }
}

resource "aws_instance" "web" {
  count = terraform.workspace != "prod" ? 1 : 0

  ami                    = var.ami_image_id
  instance_type          = "t3.micro"
  key_name               = local.service_name
  vpc_security_group_ids = [aws_security_group.web[0].id]
  subnet_id              = aws_subnet.public_a.id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 \
                -e WORDPRESS_DB_HOST=${aws_ssm_parameter.db_host.value} \
                -e WORDPRESS_DB_NAME=${local.service_name} \
                -e WORDPRESS_DB_USER=${data.aws_ssm_parameter.db_username.value} \
                -e WORDPRESS_DB_PASSWORD=${data.aws_ssm_parameter.db_password.value} \
              ghcr.io/johannez-demo/wordpress:latest
              EOF

  tags = {
    Name = "${local.name_prefix}-web"
  }
}
