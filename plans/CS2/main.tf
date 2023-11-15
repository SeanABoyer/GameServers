resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "CS2"
}

data "template_file" "application_file" {
    template = "${file("../../modules/GameInstallScripts/cs2.sh")}"
    vars = {
        password = "${random_password.password.result}",
        steamUsername = "${var.steamUsername}"
        steamPassword = "${var.steamPassword}"
        gslt = "${var.gslt}"
    }
}

module "server"{
    source = "../../modules/Server"
    scripts = [
        {
            "filename":"variablesInit.sh",
            "content":"${file("./variablesInit.sh")}"
        },
        {
            "filename":"utility.sh",
            "content":"${file("../../modules/shellScripts/utility.sh")}"
        },
        {
            "filename":"debianUpdate.sh",
            "content":"${file("../../modules/shellScripts/debianUpdate.sh")}"
        },
        {
            "filename":"mountEFS.sh",
            "content":"${file("../../modules/shellScripts/mountEFS.sh")}"
        },
        {
            "filename":"createUser.sh",
            "content":"${file("../../modules/shellScripts/createUser.sh")}"
        },
        {
            "filename":"createService.sh",
            "content":"${file("../../modules/shellScripts/createService.sh")}"
        },
        {
            "filename":"downloadAndInstall.sh",
            "content":"${file("../../modules/shellScripts/downloadAndInstall.sh")}"
        }
    ]
    application_install_script = data.template_file.application_file.rendered
    game_name = local.gamename
    instance_type = "t3.medium"
    public_ssh_key = var.public_ssh_key
    ami_name = "debian-11-amd64*"
}

module "application"{
    source = "../../modules/CS2Ports"
    ec2_security_group_id = module.server.ec2_security_group_id
    cidr_block = module.server.cidr_block
    depends_on = [module.server]
    efs_security_group_id = module.server.efs_security_group_id
}

module "dns" {
    source = "../../modules/DNS"
    dnsPrefix = var.dnsPrefix
    dnsZone = var.dnsZone
    public_ip = module.server.public_ip
    depends_on = [module.server]
}