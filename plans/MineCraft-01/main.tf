resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "${var.game_name}"
    username = "GameAdmin"
    rootdir = "/mnt/${module.server.efs_file_system_id}"
    minRam = (module.server.memory_in_bytes * 0.7) /1000000
    maxRam = (module.server.memory_in_bytes * 0.8) /1000000
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
            filename:"04_install_game",
            content:templatefile(
                "${path.root}/../../modules/GameInstallScripts/minecraft_modded_server.sh",
                {
                    serviceAccountName = "${local.username}"
                    password = "${random_password.password.result}"
                    root_dir = "${local.rootdir}"
                    minimum_ram = "${local.minRam}M"
                    maximum_ram = "${local.maxRam}M"
                    zipURL = "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.6.1_Server_Java_8.zip"
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

module "game-ports"{
    source = "../../modules/Ports/MineCraft"
    ec2_security_group_id = module.server.ec2_security_group_id
    cidr_block = module.server.cidr_block
    efs_security_group_id = module.server.efs_security_group_id
}