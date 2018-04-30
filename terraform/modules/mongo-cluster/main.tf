provider "aws" {
  region = "us-east-1"
}

###############################################
# Create Route53 DNS Zone & Record for instance
# 3 instance will have record as db[0-2].test.com
###############################################

resource "aws_route53_zone" "stage" {
  name = "test.com"
  vpc_id = "${data.terraform_remote_state.vpc.public_vpc_id[0]}"
}


resource "aws_route53_record"  "db" {
  count = 3
  zone_id = "${aws_route53_zone.stage.zone_id}"
  name = "db${count.index}.test.com" //name is db[0-2].test.com
  type = "A"
  ttl = "30"
  records = ["${element(aws_instance.db_instance.*.private_ip, count.index)}"]
}



################################################
# CREATE 3 EC2 instance for mongoDB Cluster
################################################

// Create a new keypair for ec2 instance
resource "aws_key_pair" "centos" {
  key_name   = "centos"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2q5hBylWoDvXXYkHFMjTX66iFXDXEZ9TyfC0vj4uOX4uvsJRELycEAOZTRo8IN1pInEBvSnAceiLWj/l2GEKPa07xrs2GpB+TSCyUQVKXwCLzkD+/ENHNdf82rySFI9krNjllx2wQ1CcMTMA38pI15HlNeGh6UWXWBHFmNbpQLSOilNlt7Q/I5yB8SYQlQBmgcQl1Cb8psLqI6KGsOfKRFZpcPksoEIlzRg1bLW8uProHABk4RwBs8YR6M69hU7V/0AtlO2NiXsXOCSvbCKcfQw7hAd79tBktqx9qrQ2FC0a17X+ZE+nCBIJTNesBtI1GUdJ9RSF8R2gmGvEaL27b w00f@iMac.local"
}


resource "aws_instance" "db_instance" {
  count = 3

  ami = "${var.ec2_ami_id}"
  instance_type = "${var.ec2_instance_type}"
  associate_public_ip_address = true

  key_name = "${aws_key_pair.centos.key_name}"


  # Assign subnet and security group for the instance
  subnet_id = "${data.terraform_remote_state.vpc.public_subnet_ids[count.index]}"
  vpc_security_group_ids = ["${aws_security_group.instances.id}"]

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 1000
  }

  tags {
    Name = "mongodb - ${count.index}"
  }
}

# Create security group for mongoDB Instance
resource "aws_security_group" "instances" {
    name = "mongodb"
    vpc_id = "${data.terraform_remote_state.vpc.public_vpc_id[0]}"
}

resource "aws_security_group_rule" "db_rules" {
    type = "ingress"
    security_group_id = "${aws_security_group.instances.id}"

    from_port = "27017"
    to_port = "27019"
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "ssh_rules" {
    type = "ingress"
    security_group_id = "${aws_security_group.instances.id}"

    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outgoing" {
    type = "egress"
    security_group_id = "${aws_security_group.instances.id}"

    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
