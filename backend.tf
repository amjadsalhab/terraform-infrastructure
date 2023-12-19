terraform {
  backend "s3" {
    bucket = "internal-devops-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}