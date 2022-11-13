resource "random_password" "password" {
  length = 16
  special = false
}

data "template_file" "application_file" {
    template = "${file("../../modules/GameInstallScripts/minecraft_sevtechskyblock.sh")}"
    vars = {
        password = "${random_password.password.result}"
    }
}

module "server"{
    source = "../../modules/DebianServerBullseye"
    application_install_script = data.template_file.application_file.rendered
    game_name = "SevTechAges"
    availability_zone = var.availability_zone
    instance_type = "t3.large"
    public_ssh_key = var.public_ssh_key
    ssh_username = var.ssh_username
    root_block_size = 32
}

module "application"{
    source = "../../modules/MinecraftAppConfig"
    ec2_security_group_id = module.server.security_group_id
    cidr_block = module.server.cidr_block
    depends_on = [module.server]
    efs_security_group_id = ""
}

module "application_registration" {
    source = "../../modules/RegisterServer"
    dnsPrefix = var.dnsPrefix
    dnsZone = var.dnsZone
    public_ip = module.server.public_ip
    depends_on = [module.server]
}