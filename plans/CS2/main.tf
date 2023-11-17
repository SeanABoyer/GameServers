resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "CS2"
    lgsmfilename = "cs2server"
    username = "GameAdmin"
}

data "template_file" "downloadAndInstall" {
    template = "${file("./downloadAndInstall.sh")}"
    vars = {
        steamUsername = "${var.steamUsername}"
        steamPassword = "${var.steamPassword}"
        gslt = "${var.gslt}"
        lgsmfilename = "${local.lgsmfilename}"
    }
}

data "template_file" "createService" {
    template = "${file("../../modules/shellScripts/createService.sh")}"
    vars = {
        gamename = "${local.gamename}"
    }
}

data "template_file" "createUser" {
    template = "${file("../../modules/shellScripts/createUser.sh")}"
    vars = {
        username = "${local.username}"
        password = "${random_password.password.result}"
    }
}

data "template_file" "mountEFS" {
    template = "${file("../../modules/shellScripts/mountEFS.sh")}"
    vars = {
        username = "${local.username}"
        root_dir = "/mnt/${local.gamename}"
        filesystem_id = module.server.efs_file_system_id
    }
}

data "template_file" "debianUpdate" {
    template = "${file("../../modules/shellScripts/debianUpdate.sh")}"
    vars = {}
}

data "template_file" "utility" {
    template = "${file("../../modules/shellScripts/utility.sh")}"
    vars = {}
}


module "server"{
    source = "../../modules/Server"
    scripts = [
        {
            "filename":"utility.sh",
            "content":data.template_file.utility.rendered
        },
        {
            "filename":"debianUpdate.sh",
            "content":data.template_file.debianUpdate.rendered
        },
        {
            "filename":"mountEFS.sh",
            "content":data.template_file.mountEFS.rendered
        },
        {
            "filename":"createUser.sh",
            "content":data.template_file.createUser.rendered
        },
        {
            "filename":"createService.sh",
            "content":data.template_file.createService.rendered
        },
        {
            "filename":"downloadAndInstall.sh",
            "content":data.template_file.downloadAndInstall.rendered
        }
    ]
    game_name = local.gamename
    instance_type = "t3.small"
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