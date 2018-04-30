provider "aws" {
  region = "us-east-1"
}


module "mongo-cluster" {
  source = "../../modules/mongo-cluster"

  #INPUT FOR MODULE'S VARIABLE

  #VPC we are using is staging VPC. This location is stored on S3
  vpc_state_file_location = "stage/vpc/terraform.tfstate"

  ec2_instance_type = "t2.micro"
  ec2_ami_id = "ami-b81dbfc5" //centos 7 image

}
