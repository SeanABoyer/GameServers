resource "random_password" "password" {
  length = 16
  special = false
}

locals {
    gamename = "${var.game_name}"
    username = "GameAdmin"
    rootdir = "/mnt/${module.server.efs_file_system_id}"
    minRam = floor(module.server.memory_in_bytes * 0.75)
    maxRam = floor(module.server.memory_in_bytes * 0.8)
    scripts = [
        {
            filename:"00_update_system",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/al2023/update.sh",
                {}
            )
        },
        {
            filename:"01_install_wget",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/al2023/installwget.sh",
                {}
            )
        },
        {
            filename:"02_install_unzip",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/al2023/installunzip.sh",
                {}
            )
        },
        {
            filename:"03_create_user",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/utility/createUser.sh",
                {
                    username = "${local.username}"
                    password = "${random_password.password.result}"
                }
            )
        },
        {
            filename:"04_mount_efs",
            content:templatefile(
                "${path.root}/../../modules/shellScripts/al2023/mountEFS.sh",
                {
                    username = "${local.username}"
                    root_dir = "${local.rootdir}"
                    filesystem_id = module.server.efs_file_system_id
                }
            )
        },
        {
            filename:"05_install_game",
            content:templatefile(
                "${path.root}/../../modules/GameInstallScripts/minecraft_modded_server.sh",
                {
                    serviceAccountName = "${local.username}"
                    password = "${random_password.password.result}"
                    root_dir = "${local.rootdir}"
                    minimum_ram = "${local.minRam}M"
                    maximum_ram = "${local.maxRam}M"
                    zip_url = "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.6.1_Server_Java_8.zip"
                }
            )
        }
    ]
}


module "server"{
    source = "../../modules/Server"
    scripts = local.scripts
    game_name = local.gamename
    instance_type = "t3.xlarge"
    ami_name = "al2023-ami*"
}

module "game-ports"{
    source = "../../modules/Ports/MineCraft"
    ec2_security_group_id = module.server.ec2_security_group_id
    cidr_block = module.server.cidr_block
    efs_security_group_id = module.server.efs_security_group_id
}