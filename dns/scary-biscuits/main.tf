variable "ana-host-ipv4" {
  type = "list"
}

variable "ana-host-ipv6" {
  type = "list"
}

variable "domain" {
  type = "string"
}

variable "googleauthkey" {
  type = "string"
}

variable "googleauthvalue" {
  type = "string"
}

resource "aws_route53_zone" "sb" {
  name = "${var.domain}"
}

resource "aws_route53_record" "mx" {
  zone_id = "${aws_route53_zone.sb.zone_id}"
  name    = "${aws_route53_zone.sb.name}"
  type    = "MX"
  ttl     = "300"
  records = [
    "30 aspmx5.googlemail.com",
    "30 aspmx2.googlemail.com",
    "30 aspmx3.googlemail.com",
    "30 aspmx4.googlemail.com",
    "20 alt1.aspmx.l.google.com",
    "10 aspmx.l.google.com",
    "20 alt2.aspmx.l.google.com",
  ]
}

resource "aws_route53_record" "txt" {
  zone_id = "${aws_route53_zone.sb.zone_id}"
  name    = "${aws_route53_zone.sb.name}"
  type    = "TXT"
  ttl     = "300"
  records = [
    "v=spf1 include:_spf.google.com ~all"
  ]
}

resource "aws_route53_record" "googledomainkey-txt" {
  zone_id = "${aws_route53_zone.sb.zone_id}"
  name    = "${var.googleauthkey}.${aws_route53_zone.sb.name}"
  type    = "TXT"
  ttl     = "300"
  records = [
    "${var.googleauthvalue}"
  ]
}

module "root" {
  source = "../dualstackrecord"

  zone_id = "${aws_route53_zone.sb.zone_id}"
  name = "${aws_route53_zone.sb.name}"
  a-records = "${var.ana-host-ipv4}"
  aaaa-records = "${var.ana-host-ipv6}"
}

module "blog-archive" {
  source = "../dualstackaliasrecord"

  zone_id = "${aws_route53_zone.sb.zone_id}"
  name = "blog-archive.${aws_route53_zone.sb.name}"
  alias-target = "d3ac40p387txlz.cloudfront.net."
  alias-hosted-zone-id = "Z2FDTNDATAQYW2"
}

module "files" {
  source = "../dualstackaliasrecord"

  zone_id = "${aws_route53_zone.sb.zone_id}"
  name = "files.${aws_route53_zone.sb.name}"
  alias-target = "d16y0hz62pl9qr.cloudfront.net."
  alias-hosted-zone-id = "Z2FDTNDATAQYW2"
}

module "www" {
  source = "../dualstackrecord"

  zone_id = "${aws_route53_zone.sb.zone_id}"
  name = "www.${aws_route53_zone.sb.name}"
  a-records = "${var.ana-host-ipv4}"
  aaaa-records = "${var.ana-host-ipv6}"
}

module "filehost" {
  source = "../dualstackrecord"

  zone_id = "${aws_route53_zone.sb.zone_id}"
  name = "filehost.${aws_route53_zone.sb.name}"
  a-records = "${var.ana-host-ipv4}"
  aaaa-records = "${var.ana-host-ipv6}"
}