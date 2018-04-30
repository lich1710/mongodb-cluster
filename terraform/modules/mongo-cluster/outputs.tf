output "instance_ip" {
  value = "${aws_instance.db_instance.*.public_ip}"
}
