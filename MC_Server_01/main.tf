module "server"{
    source = "../modules/DebianServer"

    game_name = "mc"
    region = var.region
    availability_zone = var.availability_zone
    instance_type = "t2.medium"
    private_ssh_key = var.private_ssh_key
    ssh_username = var.ssh_username
    root_block_size = 32
}
module "application"{
    source = "../modules/MinecraftAppConfig"
    security_group_id = module.server.security_group_id
    cidr_block = module.server.cidr_block
    depends_on = [server]
}

module "application_registration" {
    source = "../modules/RegisterServer"
    dnsPrefix = "mc"
    dnsZone = var.dnsZone
    publicIP = module.server.publicIP
    tableName = var.tableName
    lgsmCommand = "mcserver"
    depends_on = [server]
}