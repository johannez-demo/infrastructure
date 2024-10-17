# Create bastion security group to allow SSH access
resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Allow SSH access to bastion host"
  vpc_id      = aws_vpc.main.id

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
  count = var.enable_bastion ? 1 : 0

  ami                    = var.ami_image_id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = aws_subnet.public_a.id
  key_name               = local.service_name

  tags = {
    Name = "${local.name_prefix}-bastion"
  }
}
