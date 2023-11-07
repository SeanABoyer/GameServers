resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "Regrowth"
}

data "template_file" "application_file" {
    template = "${file("../../modules/GameInstallScripts/csgo.sh")}"
    vars = {
        password = "${random_password.password.result}",
        filesystem_id = module.server.efs_file_system_id,
        gamename = local.gamename,
        minimum_ram = "${(floor((module.server.memory_in_bytes/1024)* 0.6) * 1024)}",
        maximum_ram = "${(floor((module.server.memory_in_bytes/1024)* 0.8) * 1024)}"
    }
}

module "server"{
    source = "../../modules/Server"
    application_install_script = data.template_file.application_file.rendered
    game_name = local.gamename
    instance_type = "t3.xlarge"
    public_ssh_key = var.public_ssh_key
    ami_name = "al2023-ami*"
}

module "application"{
    source = "../../modules/CSGOAppConfig"
    ec2_security_group_id = module.server.ec2_security_group_id
    cidr_block = module.server.cidr_block
    depends_on = [module.server]
    #efs_security_group_id = module.server.efs_security_group_id
}

module "application_registration" {
    source = "../../modules/RegisterServer"
    dnsPrefix = var.dnsPrefix
    dnsZone = var.dnsZone
    public_ip = module.server.public_ip
    depends_on = [module.server]
}