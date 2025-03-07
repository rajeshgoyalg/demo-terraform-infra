terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket         = "terraform-state-devopsai"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locking"
  }
}

provider "aws" {
  region  = "ap-southeast-1"
  profile = "terraform-user"
}