variable "dnsPrefix" {
    type = string
}
variable "dnsZone" {
    type = string
}
variable "public_ip"{
    type = string
}
variable "tableName" {
    type = string
    default = ""
}
variable "lgsmCommand"{
    type = string
}
variable "ec2_instance_id" {
    type = string
}