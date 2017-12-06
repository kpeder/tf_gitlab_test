resource "aws_alb" "gitlab" {
  name            = "gitlab-alb-tf"
  internal        = "${var.environment["public_endpoint"] == 1 ? false : true }"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets	   = ["${data.aws_subnet.public.*.id}"]

  tags {
    Description = "Gitlab ALB"
  }
}


resource "aws_alb_listener" "gitlab_http" {
  load_balancer_arn = "${aws_alb.gitlab.arn}"
  port              = 80
  protocol          = "HTTP"
  count             = "${(1 - var.environment["hacfg"]) * (var.environment["protocol"] == "http" ? 1 : 0)}"

  default_action {
    target_group_arn = "${aws_alb_target_group.gitlab_http.arn}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "gitlab_https" {
  load_balancer_arn = "${aws_alb.gitlab.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.alb_cert_arn}"
  count             = "${(var.version == "1.2" ? 0 : 1) * (var.environment["protocol"] == "https" ? 1 : 0)}"

  default_action {
    target_group_arn = "${aws_alb_target_group.gitlab_https.arn}"
#     target_group_arn = "${aws_alb_target_group.gitlab_http.arn}"

    type             = "forward"
  }
}

resource "aws_alb_target_group" "gitlab_http" {
  name     = "gitlab-http-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_security_group.gitlab_server_inbound.vpc_id}"
  count    = "${(1 - var.environment["hacfg"]) * (var.environment["protocol"] == "http" ? 1 : 0)}"
}


resource "aws_alb_target_group" "gitlab_https" {
  name     = "gitlab-https-tg"
  port     = 80 #443
  protocol = "HTTP" #"HTTPS"
  vpc_id   = "${aws_security_group.gitlab_server_inbound.vpc_id}"
  count    = "${(var.version == "1.2" ? 0 : 1) * (var.environment["protocol"] == "https" ? 1 : 0)}"
}

resource "aws_alb_target_group_attachment" "gitlab_http" {
  target_group_arn = "${aws_alb_target_group.gitlab_http.arn}"
  target_id        = "${element(aws_instance.gitlab_server.*.id, count.index)}"
  port             = 80
  count            = "${(1 - var.environment["hacfg"]) * var.inst_count["server"] * (var.environment["protocol"] == "http" ? 1 : 0)}"
}


resource "aws_alb_target_group_attachment" "gitlab_https" {
  target_group_arn = "${aws_alb_target_group.gitlab_https.arn}"
  target_id        = "${element(aws_instance.gitlab_server.*.id, count.index)}"
  port             = 80
  count            = "${(var.version == "1.2" ? 0 : 1) * (1 - var.environment["hacfg"]) * (var.environment["protocol"] == "https" ? 1 : 0) * var.inst_count["server"]}"
}

