resource "null_resource" "gitlab_server_provisioner" {

  triggers {
    instance_ids = "${join(",", aws_instance.gitlab_server.*.id)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'waiting for dpkg lock to clear...'; sleep 30",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get -y install linux-generic-hwe-16.04 linux-cloud-tools-generic-hwe-16.04",
      "sudo apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade -y",
      "sudo apt-get update",
      "#echo 'adding docker repository'",
      "#sudo add-apt-repository -y \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "#echo 'adding java repository'",
      "#sudo apt-add-repository -y ppa:webupd8team/java",
      "#echo 'debconf shared/accepted-oracle-license-v1-1 select true'| sudo debconf-set-selections",
      "#echo 'adding ansible repository'",
      "#sudo apt-add-repository -y ppa:ansible/ansible",
      "echo 'adding gitlab repo'",
      "curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash",
      "echo 'updating repositories before installation'",
      "sudo apt-get update",
      "#echo 'installing docker'",
      "#sudo apt-get install -y docker-ce && docker -v",
      "#sudo curl -o /usr/local/bin/docker-compose -L \"https://github.com/docker/compose/releases/download/1.15.0/docker-compose-$(uname -s)-$(uname -m)\"",
      "#sudo chmod +x /usr/local/bin/docker-compose && docker-compose -v",
      "#echo 'installing java'",
      "#sudo apt-get install -y oracle-java8-installer",
      "#echo 'installing ansible'",
      "#sudo apt-get install -y ansible",
      "echo 'installing postfix'",
      "sudo apt-get install -y postfix",
      "echo 'installing gitlab'",
      "sudo EXTERNAL_URL='http://${element(aws_instance.gitlab_server.*.public_dns, count.index)}' apt-get install -y gitlab-ee"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      host = "${element(aws_instance.gitlab_server.*.public_dns, count.index)}"
    }

  }

  count = "${var.inst_count["server"]}"

}

resource "null_resource" "gitlab_runner_provisioner" {

  triggers {
    instance_ids = "${join(",", aws_instance.gitlab_runner.*.id)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'waiting for dpkg lock to clear...'; sleep 30",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get -y install linux-generic-hwe-16.04 linux-cloud-tools-generic-hwe-16.04",
      "sudo apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade -y",
      "sudo apt-get update",
      "echo 'adding docker repository'",
      "sudo add-apt-repository -y \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "#echo 'adding java repository'",
      "#sudo apt-add-repository -y ppa:webupd8team/java",
      "#echo 'debconf shared/accepted-oracle-license-v1-1 select true'| sudo debconf-set-selections",
      "#echo 'adding ansible repository'",
      "#sudo apt-add-repository -y ppa:ansible/ansible",
      "echo 'adding gitlab repo'",
      "curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash",
      "echo 'updating repositories before installation'",
      "sudo apt-get update",
      "echo 'installing docker'",
      "sudo apt-get install -y docker-ce && docker -v",
      "sudo curl -o /usr/local/bin/docker-compose -L \"https://github.com/docker/compose/releases/download/1.15.0/docker-compose-$(uname -s)-$(uname -m)\"",
      "sudo chmod +x /usr/local/bin/docker-compose && docker-compose -v",
      "#echo 'installing java'",
      "#sudo apt-get install -y oracle-java8-installer",
      "#echo 'installing ansible'",
      "#sudo apt-get install -y ansible",
      "echo 'installing gitlab'",
      "sudo apt-get install -y gitlab-runner"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      host = "${element(aws_instance.gitlab_runner.*.public_dns, count.index)}"
    }

  }

  count = "${var.inst_count["runner"]}"

}

resource "null_resource" "gitlab_server_restore" {

  depends_on = [ "null_resource.gitlab_server_provisioner" ]

  triggers {
    instance_ids = "${join(",", aws_instance.gitlab_server.*.id)}"
  }

  provisioner "file" {
    source      = "${var.gitlab_server_backup["archive_to_restore"]}"
    destination = "/home/ubuntu/restore_archive.tar"
  }

  provisioner "file" {
    source      = "gitlab-secrets.json"
    destination = "/home/ubuntu/gitlab-secrets.json"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /home/ubuntu/restore_archive.tar /var/opt/gitlab/backups/restore_archive_gitlab_backup.tar",
      "sudo gitlab-rake gitlab:backup:restore BACKUP=restore_archive force=yes",
      "sudo cp gitlab-secrets.json /etc/gitlab/gitlab-secrets.json && sudo chmod 0600 /etc/gitlab/gitlab-secrets.json && sudo chown root:root /etc/gitlab/gitlab-secrets.json",
      "sudo rm -f /var/opt/gitlab/backups/restore_archive_gitlab_backup.tar gitlab-secrets.json"
    ]
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    host = "${element(aws_instance.gitlab_server.*.public_dns, count.index)}"
  }

  count = "${var.gitlab_server_backup["restore_flag"]}"

}
