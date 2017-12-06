#this little bit gets the list of public subnets from AWS based on the current zone
#The ALB requires a list of subnets to attach to.

#grab the VPC ID for the region we're using
data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

output "vpc_list" {
        value = "${data.aws_vpc.selected.id}"
}

#Grab ths list of subnet IDs
data "aws_subnet_ids" "public" {
  vpc_id = "${data.aws_vpc.selected.id}"
}

data "aws_subnet" "public" {
  count = "${length(data.aws_subnet_ids.public.ids)}"
  id = "${data.aws_subnet_ids.public.ids[count.index]}"
}

output "subnet_cidr_blocks" {
  value = ["${data.aws_subnet.public.*.id}"]
}


