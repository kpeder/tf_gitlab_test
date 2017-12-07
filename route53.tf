resource "aws_route53_record" "registration_endpoint" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.dns["gitlab_url"]}"
  type    = "${var.dns["record_type"]}"
  ttl     = "${var.dns["record_ttl"]}"
  records = ["${aws_alb.gitlab.dns_name}"]
  count = 1
}
