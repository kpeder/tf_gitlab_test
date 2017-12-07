resource "aws_instance" "gitlab_runner" {

  /* set the initial key for the instance */
  key_name = "${var.keypair}"

  /* optionally, set the role */
  #iam_instance_profile = "AnsibleTestRole"  

  /* select the appropriate AMI (can generate one using enclosed packer template) */
  ami = "${var.inst_amid["${var.region["primary"]}"]}"
  instance_type = "${var.inst_type["runner"]}"

  /* delete the volume on termination */
  root_block_device {
    volume_size = "${var.inst_disk_sz["runner"]}"
    delete_on_termination = true
  }

  /* security group membership */
  security_groups = ["${aws_security_group.gitlab_runner_inbound.name}", "default" ]

  /* number of hosts to create */
  count = "${var.inst_count["runner"]}"

  tags {
    Role = "gitlab_runner"
    Platform = "Ubuntu 16.04 LTS"
    Tier = "gitlab"
  }
}

resource "aws_security_group" "gitlab_runner_inbound" {
  description = "Allow inbound ssh traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.cidr}"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = "${var.cidr}"
  }
}

output "gitlab_runner_public_address(es)" {
  value = "${join(",", aws_instance.gitlab_runner.*.public_dns)}"
}
