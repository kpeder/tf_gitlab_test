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

variable "inst_type"  { default = "t2.large" }
variable "inst_count" { default = 1 }

variable "inst_amid" {
  type = "map"
  default = {
    "us-west-2" = "ami-0a00ce72"
    "us-east-1" = "ami-da05a4a0"
  }
}
