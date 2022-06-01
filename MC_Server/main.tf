resource "random_password" "password" {
  length           = 16
}
data "template_file" "applicationfile" {
    template = "${file("../modules/GameInstallScripts/minecraft.sh")}"
    vars = {
        password = random_password.password
    }
    depends_on = [random_password.password]
}

module "server"{
    source = "../modules/DebianServer"
    application_install_script = data.template_file.applicationfile
    game_name = "mc"
    availability_zone = var.availability_zone
    instance_type = "t2.medium"
    public_ssh_key = var.public_ssh_key
    ssh_username = var.ssh_username
    root_block_size = 32
}

module "application"{
    source = "../modules/MinecraftAppConfig"
    security_group_id = module.server.security_group_id
    cidr_block = module.server.cidr_block
    depends_on = [module.server]
}

module "application_registration" {
    source = "../modules/RegisterServer"
    dnsPrefix = "mc"
    dnsZone = var.dnsZone
    public_ip = module.server.public_ip
    tableName = var.tableName
    lgsmCommand = "mcserver"
    ec2_instance_id = module.server.ec2_instance_id
    depends_on = [module.server]
}