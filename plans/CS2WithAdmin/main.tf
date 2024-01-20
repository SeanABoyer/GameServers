resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "CS2WithAdmin"
    lgsmfilename = "cs2server"
    username = "GameAdmin"
    rootdir = "/mnt/${module.server.efs_file_system_id}"
    gamebasedir = "${local.rootdir}/CS2"
    metaModLink = "https://mms.alliedmods.net/mmsdrop/1.11/mmsource-1.11.0-git1153-linux.tar.gz"
    metaModDirectory = "/home"
    counterStrikeSharpLink = "https://github.com/roflmuffin/CounterStrikeSharp/releases/latest"
    counterStrikeSharpDirectory = "/home"
    CS2startScriptFullPath = "${local.gamebasedir}/startServer.sh"
    CS2stopScriptFullPath = "${local.gamebasedir}/stopServer.sh"
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
            filename:"07_install_metamod",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/apps/installMetaMod.sh",
                {
                    link = "${local.metaModLink}"
                    directory = "${local.metaModDirectory}"
                }
            )
        },
        {
            filename:"07_install_counter_strike_sharp",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/apps/instalCounterStrikeSharp.sh",
                {
                    link = "${local.counterStrikeSharpLink}"
                    directory = "${local.counterStrikeSharpDirectory}"
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

module "cs2-ports"{
    source = "../../modules/Ports/CS2"
    ec2_security_group_id = module.server.ec2_security_group_id
    cidr_block = module.server.cidr_block
    efs_security_group_id = module.server.efs_security_group_id
}

module "rcon-ports"{
    source = "../../modules/Ports/RCON"
    ec2_security_group_id = module.server.ec2_security_group_id
    cidr_block = module.server.cidr_block
    efs_security_group_id = module.server.efs_security_group_id
}