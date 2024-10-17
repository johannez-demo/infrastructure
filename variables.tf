variable "ami_image_id" {
  description = "AMI ID for a EC2 instances"
  type        = string
  default     = "ami-079c0d2990b4033f4"
}

variable "availability_zones" {
  description = "Availability zones to deploy into"
  type = object({
    zone_a = string
    zone_b = string
  })
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

variable "enable_bastion" {
  description = "Whether to create the bastion host"
  type        = bool
  default     = true
}

variable "region" {
  description = "The AWS region to deploy to"
  type        = string
}
