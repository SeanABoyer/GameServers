resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "CS2"
    lgsmfilename = "cs2server"
    username = "GameAdmin"
    rootdir = "/mnt/${module.server.efs_file_system_id}"
    gamebasedir = "${local.rootdir}/CS2"
    rconbasedir = "${local.rootdir}/cs2-rcon-panel-master"
    CS2startScriptFullPath = "${local.gamebasedir}/startServer.sh"
    CS2stopScriptFullPath = "${local.gamebasedir}/stopServer.sh"
    RCONstartScriptFullPath = "${local.rconbasedir}/startServer.sh"
    RCONstopScriptFullPath = "${local.rconbasedir}/stopServer.sh"
    scripts = [
        {
            filename:"00_install_ssm_agent",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/debian/ssmAgent.sh",
                {}
            )
        },
        {
            filename:"01_update_system",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/debian/update.sh",
                {}
            )
        },
        {
            filename:"02_create_user",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/utility/createUser.sh",
                {
                    username = "${local.username}"
                    password = "${random_password.password.result}"
                }
            )
        },
        {
            filename:"03_mount_efs",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/utility/mountEFS.sh",
                {
                    username = "${local.username}"
                    root_dir = "${local.rootdir}"
                    filesystem_id = module.server.efs_file_system_id
                }
            )
        },
        {
            filename:"04_install_cs2",
            content:templatefile(
                "${path.root}/CS2Install.sh",
                {
                    steamUsername = "${var.steamUsername}"
                    steamPassword = "${var.steamPassword}"
                    gslt = "${var.steamGSLT}"
                    lgsmfilename = "${local.lgsmfilename}"
                    game_dir = "${local.gamebasedir}"
                    gamename = "${local.gamename}"
                    startScriptFullPath = "${local.CS2startScriptFullPath}"
                    stopScriptFullPath = "${local.CS2stopScriptFullPath}"
                }
            )
        },
        {
            filename:"05_create_cs2_service",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/utility/createService.sh",
                {
                    gamename = "${local.gamename}"
                    username = "${local.username}"
                    dir = "${local.gamebasedir}"
                    startScriptFullPath = "${local.CS2startScriptFullPath}"
                    stopScriptFullPath = "${local.CS2stopScriptFullPath}"
                }
            )
        },
        {
            filename:"06_start_cs2_service",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/utility/startService.sh",
                {
                    gamename = "${local.gamename}"
                }
            )
        },
        {
            filename:"07_install_rcon_web_app",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/rcon/installRcon.sh",
                {
                    username = "${local.username}"
                    gamename = "${local.gamename}_RCON"
                    rcon_dir = "${local.rconbasedir}"
                    startScriptFullPath = "${local.RCONstartScriptFullPath}"
                    stopScriptFullPath = "${local.RCONstopScriptFullPath}"
                }
            )
        },
        {
            filename:"08_create_rcon_service",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/utility/createService.sh",
                {
                    gamename = "${local.gamename}_RCON"
                    username = "${local.username}"
                    dir = "${local.rconbasedir}"
                    startScriptFullPath = "${local.RCONstartScriptFullPath}"
                    stopScriptFullPath = "${local.RCONstopScriptFullPath}"
                }
            )
        },
        {
            filename:"09_start_rcon_service",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/utility/startService.sh",
                {
                    gamename = "${local.gamename}_RCON"
                }
            )
        }
    ]
}


module "server"{
    source = "../../modules/Server"
    scripts = local.scripts
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