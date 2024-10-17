# Create a security group for the RDS instance
resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-db-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.cidr.public_subnet_a]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_anywhere]
  }

  tags = {
    Name = "${local.name_prefix}-db-sg"
  }
}

# Create an RDS subnet group
resource "aws_db_subnet_group" "rds" {
  name = "${local.name_prefix}-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "${local.name_prefix}-db-subnet-group"
  }
}

# Create an RDS instance in the private subnet
resource "aws_db_instance" "rds" {
  identifier             = "${local.name_prefix}-db"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true

  tags = {
    Name = "${local.name_prefix}-db"
  }
}
