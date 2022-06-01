data aws_route53_zone "DNSZone"{
  name = var.dnsZone
}
resource aws_route53_record  "mcDNSRecord" {
  zone_id = data.aws_route53_zone.DNSZone.zone_id
  name = "${var.dnsPrefix}.${var.dnsZone}"
  type = "A"
  ttl = "300"
  records = [var.publicIP]
}

data "aws_dynamodb_table" "DBtable" {
  name = var.tableName
}
resource "aws_dynamodb_table_item" "dynamodbEntry" {
  table_name = data.aws_dynamodb_table.DBtable.name
  hash_key = data.aws_dynamodb_table.DBtable.hash_key

  item = jsonencode(
    {
      "ec2ID":{"S":"${aws_instance.mc_server.id}"},
      "dnsName":{"S":"${aws_route53_record.mcDNSRecord.name}"},
      "startCommand":{"S":"cd ~ && ./${var.lgsmCommand} start"},
      "stopCommand":{"S":"cd ~ && ./${var.lgsmCommand} stop"},
    }
  )
}