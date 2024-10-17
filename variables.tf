variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}

variable "cidr" {
  description = "CIDR blocks for the VPC and subnets"
  type = object({
    vpc              = string
    public_subnet_a  = string
    private_subnet_a = string
    public_subnet_b  = string
    private_subnet_b = string
  })
}

variable "cidr_anywhere" {
  description = "The CIDR block for allowing all traffic"
  type        = string
  default     = "0.0.0.0/0"
}

variable "availability_zones" {
  description = "Availability zones to deploy into"
  type = object({
    zone_a = string
    zone_b = string
  })
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}
