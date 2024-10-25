provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "demo-state-bucket"
    key            = "demo.tfstate"
    region         = "us-west-2"
    dynamodb_table = "demo-terraform-lock-table"
    encrypt        = true
  }
}
