# Read the VPC state file to get VPC info
# Need to provide the location of the VPC State file
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "unique-s3-bucket3"
    region = "us-east-1"
    encrypt = true
    key = "${var.vpc_state_file_location}"
  }
}


# state file location contains VPC info
variable "vpc_state_file_location" {
  description = "Location of the state file of the VPC"
}

# Variable relating to ec2 instance
variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "ec2_ami_id" {
  default = "ami-b81dbfc5" // Official centos 7 Image
}







data "aws_availability_zones" "all" {}
