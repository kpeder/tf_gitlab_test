resource "aws_alb" "gitlab" {
  name            = "gitlab-alb-tf"
  internal	  = "false"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets	   = ["${data.aws_subnet.public.*.id}"]

  tags {
    Description = "Gitlab ALB"
  }
}


resource "aws_alb_listener" "gitlab_https" {
  load_balancer_arn = "${aws_alb.gitlab.arn}"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${var.alb_cert_arn}"
  #count = "1"

  default_action {
    target_group_arn = "${aws_alb_target_group.gitlab_https.arn}"

    type             = "forward"
  }
}

# while the gitlab server is running on 80, the ALB is on 443.
resource "aws_alb_target_group" "gitlab_https" {
  name     = "gitlab-https-tg"
  port     = 80 
  protocol = "HTTP" 
  vpc_id   = "${aws_security_group.gitlab_server_inbound.vpc_id}"
 # count = "1"
}


resource "aws_alb_target_group_attachment" "gitlab_https" {
  target_group_arn = "${aws_alb_target_group.gitlab_https.arn}"
  target_id        = "${element(aws_instance.gitlab_server.*.id, count.index)}"
  port             = 80
#  count = "1"
}

