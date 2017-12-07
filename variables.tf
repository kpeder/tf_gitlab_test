/* Global variables */
variable "keypair" { default = "cortmaior-key" }
variable  "alb_cert_arn" { default = "arn:aws:acm:us-west-2:272454344428:certificate/4217e124-da93-4b2d-b450-e32a2f25dde5" }
variable  "hosted_zone_id" { default = "Z2QZ6OE3UET6VF" }

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

#setup variable for the DNS zone 
#change the gitlab_url to match the name of the server you want in the zone
# IE: gitlab-server.example.com

variable "dns" {
  type = "map"

  default = {
    gitlab_url = "gitlab-server"
    record_ttl  = 60
    record_type = "CNAME"  
  }
}

#initialize vpc_id
variable "vpc_id" { default =""}

#setup for ALB CERT
#variable "environment" {
#  type = "map"
#
#  default = {
#    description     = "Gitlab environment"
#    hacfg           = false
#    name            = "Default"
#    orchestrator    = ""
#    public_endpoint = true
##    custom_catalog  = ""
#    protocol        = "https"
#  }
#}

#This is for ALB
variable "version" {
  type    = "string"
  default = "latest"
}

variable "cidr" {
	type = "list"
	default = ["0.0.0.0/0"]
}
