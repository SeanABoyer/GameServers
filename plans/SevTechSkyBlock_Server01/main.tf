resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "SevTechSkyBlock"
}

data "template_file" "application_file" {
    template = "${file("../../modules/GameInstallScripts/minecraft_sevtechskyblock.sh")}"
    vars = {
        password = "${random_password.password.result}",
        filesystem_id = module.server.efs_file_system_id,
        gamename = local.gamename,
        minimum_ram = "${module.server.memory_in_bytes * 0.6}",
        maximum_ram = "${module.server.memory_in_bytes * 0.8}"
    }
}

module "server"{
    source = "../../modules/Server"
    application_install_script = data.template_file.application_file.rendered
    game_name = local.gamename
    instance_type = "t4g.xlarge"
    public_ssh_key = var.public_ssh_key
    ssh_username = var.ssh_username
}

module "application"{
    source = "../../modules/MinecraftAppConfig"
    ec2_security_group_id = module.server.ec2_security_group_id
    cidr_block = module.server.cidr_block
    depends_on = [module.server]
    efs_security_group_id = module.server.efs_security_group_id
}

module "application_registration" {
    source = "../../modules/RegisterServer"
    dnsPrefix = var.dnsPrefix
    dnsZone = var.dnsZone
    public_ip = module.server.public_ip
    depends_on = [module.server]
}