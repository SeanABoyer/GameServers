resource "random_password" "password" {
  length = 16
  special = false
}
data "template_file" "application_file" {
    template = "${file("../../modules/GameInstallScripts/project_zomboid.sh")}"
    vars = {
        password = "${random_password.password.result}"
    }
}

module "server"{
    source = "../../modules/DebianServerBullseye"
    application_install_script = data.template_file.application_file.rendered
    game_name = "Project_Zomboid"
    availability_zone = var.availability_zone
    instance_type = "t2.medium"
    public_ssh_key = var.public_ssh_key
    ssh_username = var.ssh_username
    root_block_size = 32
}

module "application"{
    source = "../../modules/ProjectZomboidAppConfig"
    security_group_id = module.server.security_group_id
    cidr_block = module.server.cidr_block
    depends_on = [module.server]
}

module "application_registration" {
    source = "../../modules/RegisterServer"
    dnsPrefix = var.dnsPrefix
    dnsZone = var.dnsZone
    public_ip = module.server.public_ip
    tableName = var.tableName
    lgsmCommand = "pzserver"
    ec2_instance_id = module.server.ec2_instance_id
    depends_on = [module.server]
}