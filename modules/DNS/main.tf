data aws_route53_zone "DNSZone"{
  name = var.dnsZone
}
resource aws_route53_record  "DNSRecord" {
  zone_id = data.aws_route53_zone.DNSZone.zone_id
  name = "${var.dnsPrefix}.${var.dnsZone}"
  type = "A"
  ttl = "300"
  records = [var.public_ip]
}