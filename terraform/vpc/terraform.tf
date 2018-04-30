
terraform {
  backend "s3" {
    # Provide your own bucket name here
    bucket = "unique-s3-bucket3"
    region = "us-east-1"
    encrypt = true
    key = "stage/vpc/terraform.tfstate"
  }
}
