/* set up aws provider and
   and regional preference */
provider "aws" {
  region  = "${var.region["primary"]}"
  profile = "${var.aws_profile}"
}
