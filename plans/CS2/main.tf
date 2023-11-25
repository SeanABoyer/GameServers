resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "CS2"
    lgsmfilename = "cs2server"
    username = "GameAdmin"
    rootdir = "/mnt/${local.gamename}"
    rcondir = "${local.rootdir}/cs2-rcon-panel-master"
    CS2startScriptFullPath = "${local.rootdir}/startServer.sh"
    CS2stopScriptFullPath = "${local.rootdir}/stopServer.sh"
    RCONstartScriptFullPath = "${local.rcondir}/startServer.sh"
    RCONstopScriptFullPath = "${local.rcondir}/stopServer.sh"
}

data "template_file" "CS2Install" {
    template = "${file("./CS2Install.sh")}"
    vars = {
        steamUsername = "${var.steamUsername}"
        steamPassword = "${var.steamPassword}"
        gslt = "${var.steamGSLT}"
        lgsmfilename = "${local.lgsmfilename}"
        root_dir = "${local.rootdir}"
        gamename = "${local.gamename}"
        startScriptFullPath = "${local.CS2startScriptFullPath}"
        stopScriptFullPath = "${local.CS2stopScriptFullPath}"
    }
}

data "template_file" "createCS2Service" {
    template = "${file("../../modules/shellScripts/createService.sh")}"
    vars = {
        gamename = "${local.gamename}"
        username = "${local.username}"
        root_dir = "${local.rootdir}"
        startScriptFullPath = "${local.CS2startScriptFullPath}"
        stopScriptFullPath = "${local.CS2stopScriptFullPath}"

    }
}

data "template_file" "installRcon" {
    template = "${file("../../modules/shellScripts/installRcon.sh")}"
    vars = {
        username = "${local.username}"
        rcon_dir = "${local.rcondir}"
        startScriptFullPath = "${local.RCONstartScriptFullPath}"
        stopScriptFullPath = "${local.RCONstopScriptFullPath}"
    }
}

data "template_file" "createRconService" {
    template = "${file("../../modules/shellScripts/createService.sh")}"
    vars = {
        gamename = "${local.gamename}_RCON"
        username = "${local.username}"
        root_dir = "${local.rcondir}"
        startScriptFullPath = "${local.RCONstartScriptFullPath}"
        stopScriptFullPath = "${local.RCONstopScriptFullPath}"

    }
}

data "template_file" "startCS2Service" {
    template = "${file("../../modules/shellScripts/startService.sh")}"
    vars = {
        gamename = "${local.gamename}"
    }
}

data "template_file" "startRCONService" {
    template = "${file("../../modules/shellScripts/startService.sh")}"
    vars = {
        gamename = "${local.gamename}_RCON"
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
        root_dir = "${local.rootdir}"
        filesystem_id = module.server.efs_file_system_id
    }
}

data "template_file" "update" {
    template = "${file("../../modules/shellScripts/debian/update.sh")}"
    vars = {}
}

data "template_file" "debianSSMAgent" {
    template = "${file("../../modules/shellScripts/debian/deploySSMAgent.sh")}"
    vars = {}
}




module "server"{
    source = "../../modules/Server"
    scripts = [
        {
            "filename":"01_debianSSMAgent.sh",
            "content":data.template_file.debianSSMAgent.rendered
        },
        {
            "filename":"02_update.sh",
            "content":data.template_file.update.rendered
        },
        {
            "filename":"03_createUser.sh",
            "content":data.template_file.createUser.rendered
        },
        {
            "filename":"04_mountEFS.sh",
            "content":data.template_file.mountEFS.rendered
        },
        {
            "filename":"05_CS2Install.sh",
            "content":data.template_file.CS2Install.rendered
        },
        {
            "filename":"06_createCS2Service.sh",
            "content":data.template_file.createCS2Service.rendered
        },
        {
            "filename":"07_startCS2Service.sh",
            "content":data.template_file.startCS2Service.rendered
        },
        {
            "filename":"08_installRcon.sh",
            "content":data.template_file.installRcon.rendered
        },
        {
            "filename":"08_createRCONService.sh",
            "content":data.template_file.createRconService.rendered
        },
        {
            "filename":"08_startRCONService.sh",
            "content":data.template_file.startRCONService.rendered
        }
    ]
    game_name = local.gamename
    instance_type = "t3.small"
    ami_name = "debian-11-amd64*"
}

module "application"{
    source = "../../modules/Ports/CS2"
    ec2_security_group_id = module.server.ec2_security_group_id
    cidr_block = module.server.cidr_block
    depends_on = [module.server]
    efs_security_group_id = module.server.efs_security_group_id
}

# module "dns" {
#     source = "../../modules/DNS"
#     dnsPrefix = var.gamename
#     dnsZone = var.dnsZone
#     public_ip = module.server.public_ip
#     depends_on = [module.server]
# }