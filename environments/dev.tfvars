region = "us-west-2"

cidr = {
  vpc              = "10.0.0.0/16"
  public_subnet_a  = "10.0.1.0/24"
  private_subnet_a = "10.0.2.0/24"
  public_subnet_b  = "10.0.3.0/24"
  private_subnet_b = "10.0.4.0/24"
}

availability_zones = {
  zone_a = "us-west-2a"
  zone_b = "us-west-2b"
}
