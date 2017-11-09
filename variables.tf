/* Global variables */
variable "keypair" {}

/* Region-specific setup is below. Uses
   multiple regions, "primary" & "backup" for DR. */

variable "region" {
  type        = "map"
  default = { 
    "primary" = "us-west-2"
    "backup"  = "us-east-1"
  }
}

variable "aws_profile" { default = "default" }

variable "inst_type"  { 
  type = "map"
  default = {
    "server" = "t2.large"
    "runner" = "t2.small"
  }
}

variable "inst_disk_sz" {
  type = "map"
  default = {
    "server" = "60"
    "runner" = "20"
  }
}

variable "inst_count" {
  type = "map"
  default = {
    "server" = "1"
    "runner" = "2"
  }
}

variable "inst_amid" {
  type = "map"
  default = {
    "us-west-2" = "ami-0a00ce72"
    "us-east-1" = "ami-da05a4a0"
  }
}

variable "gitlab_version" { 
  type="map"
  default = {
    "server" = "10.1.1-ee.0"
    "runner" = "10.1.0"
  }
}

variable "gitlab_server_backup" {
  type = "map"
  description = <<DESC
  A variable map to configure an optional gitlab restore
    - set "archive_to_restore" to a local file path containing a gitlab backup archive; this will be copied and restored
      (this shouldn't change, provisioner uses restore_archive for stub amd gitlab-rake uses gitlab_backup.tar for suffix filter)
    - set "restore_flag" to "1" for enabled and "0" for disabled
  DESC
  default = {
    "archive_to_restore" = "restore_archive_gitlab_backup.tar"
    "restore_flag" = "0"
  }
}
