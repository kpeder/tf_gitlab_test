resource "aws_instance" "ubuntu16" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* optionally, set the role */
  #iam_instance_profile = "AnsibleTestRole"  

  /* select the appropriate AMI (can generate one using enclosed packer template) */
  ami = "${var.inst_amid["${var.region["primary"]}"]}"
  instance_type = "${var.inst_type}"

  /* delete the volume on termination */
  root_block_device {
    delete_on_termination = true
  }

  /* security group membership */
  security_groups = ["${aws_security_group.allow_ssh_inbound.name}"]

  /* number of hosts to create */
  count = "${var.inst_count}"

  tags {
    Name = "ubuntu"
    Platform = "Ubuntu 16.04 LTS"
    Tier = "test"
  }
}

resource "aws_security_group" "allow_ssh_inbound" {
  name        = "tf_allow_ssh_inbound_kpederson"
  description = "Allow inbound ssh traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

output "ubuntu16_public_address(es)" {
  value = "${join(",", aws_instance.ubuntu16.*.public_dns)}"
}
