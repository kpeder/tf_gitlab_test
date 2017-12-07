# Begin ALB security group and rules


resource "aws_security_group" "alb" {
  name   = "alb-sg-tf"
  vpc_id = "${aws_security_group.gitlab_server_inbound.vpc_id}"
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}

resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.alb.id}"
}


#  server security group and rules
resource "aws_security_group" "server" {
  name   = "gitlab-server"
  vpc_id = "${aws_security_group.gitlab_server_inbound.vpc_id}"
}

resource "aws_security_group_rule" "server_ingress_all" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = "${aws_security_group.server.id}"
}


resource "aws_security_group_rule" "server_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.server.id}"
}

resource "aws_security_group_rule" "alb_ingress_http_server" {
  description = "the problem"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.gitlab_server_inbound.id}"
  source_security_group_id = "${aws_security_group.alb.id}"
}
